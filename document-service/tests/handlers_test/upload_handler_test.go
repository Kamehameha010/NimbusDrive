package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"nimbus-document-upload-service/internal/handlers"
	req "nimbus-document-upload-service/internal/models/requests"
	"testing"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockS3Client is a mock implementation of the S3ClientAPI interface
type MockS3Client struct {
	mock.Mock
}

func (m *MockS3Client) CreateMultipartUpload(ctx context.Context, objectKey string) (*s3.CreateMultipartUploadOutput, error) {

	args := m.Called(ctx, objectKey)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*s3.CreateMultipartUploadOutput), args.Error(1)
}

func (m *MockS3Client) UploadPart(ctx context.Context, objectKey string, uploadID string, partNumber int32, body []byte) (*s3.UploadPartOutput, error) {
	args := m.Called(ctx, objectKey, uploadID, partNumber, body)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*s3.UploadPartOutput), args.Error(1)
}

func (m *MockS3Client) CompleteMultipartUpload(ctx context.Context, objectKey string, uploadID string, parts []types.CompletedPart) (*s3.CompleteMultipartUploadOutput, error) {
	args := m.Called(ctx, objectKey, uploadID, parts)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*s3.CompleteMultipartUploadOutput), args.Error(1)
}

func (m *MockS3Client) UploadFile(ctx context.Context, objectKey string, body *[]byte) (*s3.PutObjectOutput, error) {
	args := m.Called(ctx, objectKey, body)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*s3.PutObjectOutput), args.Error(1)
}

func (m *MockS3Client) CreatePresignedURL(objectKey string) (string, error) {
	args := m.Called(objectKey)
	return args.String(0), args.Error(1)
}

func TestStartMultipartUploadHandler(t *testing.T) {
	mockS3Client := new(MockS3Client)
	handler := handlers.NewUploadHandler(mockS3Client)

	app := fiber.New()
	app.Post("/upload/start", handler.StartMultipartUploadHandler)

	t.Run("success", func(t *testing.T) {
		uploadID := "test-upload-id"
		mockS3Client.On("CreateMultipartUpload", mock.Anything, "files/test.txt").Return(&s3.CreateMultipartUploadOutput{
			UploadId: &uploadID,
		}, nil).Once()

		startReq := req.StartUploadRequest{FileName: "test.txt"}
		body, _ := json.Marshal(startReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/start", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusOK, resp.StatusCode)

		var result map[string]string
		json.NewDecoder(resp.Body).Decode(&result)

		log.Printf("hola %v", result)
		assert.Equal(t, "test-upload-id", result["upload_id"])
		assert.Equal(t, "test.txt", result["filename"])
		assert.Equal(t, "started", result["status"])
		mockS3Client.AssertExpectations(t)
	})

	t.Run("s3 fail", func(t *testing.T) {
		mockS3Client.On("CreateMultipartUpload", mock.Anything, "files/test.txt").Return(nil, errors.New("S3 error")).Once()

		startReq := req.StartUploadRequest{FileName: "test.txt"}
		body, _ := json.Marshal(startReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/start", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusInternalServerError, resp.StatusCode)
		mockS3Client.AssertExpectations(t)
	})
}

func TestUploadChunkHandler(t *testing.T) {
	mockS3Client := new(MockS3Client)
	handler := handlers.NewUploadHandler(mockS3Client)

	app := fiber.New()
	app.Post("/upload/chunk", handler.UploadChunkHandler)

	t.Run("success", func(t *testing.T) {
		mockS3Client.On("UploadPart", mock.Anything, "files/test.txt", "upload-id", int32(1), []byte("chunk")).Return(&s3.UploadPartOutput{}, nil).Once()

		chunkReq := req.UploadChunkRequest{
			FileName:     "test.txt",
			UploadID:     "upload-id",
			ChunkNumber:  1,
			ChunkContent: []byte("chunk"),
		}
		body, _ := json.Marshal(chunkReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/chunk", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusAccepted, resp.StatusCode)
		mockS3Client.AssertExpectations(t)
	})

	t.Run("s3 fail", func(t *testing.T) {
		mockS3Client.On("UploadPart", mock.Anything, "files/test.txt", "upload-id", int32(1), []byte("chunk")).Return(nil, errors.New("S3 error")).Once()

		chunkReq := req.UploadChunkRequest{
			FileName:     "test.txt",
			UploadID:     "upload-id",
			ChunkNumber:  1,
			ChunkContent: []byte("chunk"),
		}
		body, _ := json.Marshal(chunkReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/chunk", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusInternalServerError, resp.StatusCode)
		mockS3Client.AssertExpectations(t)
	})
}

func TestCompleteMultipartUploadHandler(t *testing.T) {
	mockS3Client := new(MockS3Client)
	handler := handlers.NewUploadHandler(mockS3Client)

	app := fiber.New()
	app.Post("/upload/complete", handler.CompleteMultipartUploadHandler)

	t.Run("success", func(t *testing.T) {
		parts := []req.ChunkPartsRequest{
			{ETag: "etag1", PartNumber: 1},
		}
		awsParts := []types.CompletedPart{
			{ETag: &parts[0].ETag, PartNumber: &parts[0].PartNumber},
		}

		mockS3Client.On("CompleteMultipartUpload", mock.Anything, "files/test.txt", "upload-id", awsParts).Return(&s3.CompleteMultipartUploadOutput{}, nil).Once()

		completeReq := req.UploadCompleteRequest{
			FileName:  "test.txt",
			UploadID:  "upload-id",
			PartETags: parts,
		}
		body, _ := json.Marshal(completeReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/complete", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusOK, resp.StatusCode)

		var result map[string]string
		bodyBytes, _ := io.ReadAll(resp.Body)
		json.Unmarshal(bodyBytes, &result)

		assert.Equal(t, "Upload completed successfully", result["message"])

		mockS3Client.AssertExpectations(t)
	})

	t.Run("s3 fail", func(t *testing.T) {
		parts := []req.ChunkPartsRequest{
			{ETag: "etag1", PartNumber: 1},
		}
		awsParts := []types.CompletedPart{
			{ETag: &parts[0].ETag, PartNumber: &parts[0].PartNumber},
		}
		mockS3Client.On("CompleteMultipartUpload", mock.Anything, "files/test.txt", "upload-id", awsParts).Return(nil, errors.New("S3 error")).Once()

		completeReq := req.UploadCompleteRequest{
			FileName:  "test.txt",
			UploadID:  "upload-id",
			PartETags: parts,
		}
		body, _ := json.Marshal(completeReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/complete", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusInternalServerError, resp.StatusCode)
		mockS3Client.AssertExpectations(t)
	})
}

func TestUploadFileHandler(t *testing.T) {
	mockS3Client := new(MockS3Client)
	handler := handlers.NewUploadHandler(mockS3Client)

	app := fiber.New()
	app.Post("/upload/file", handler.UploadFileHandler)

	t.Run("success", func(t *testing.T) {
		content := []byte("file content")
		mockS3Client.On("UploadFile", mock.Anything, "files/test.txt", &content).Return(&s3.PutObjectOutput{}, nil).Once()

		uploadReq := req.UploadRequest{
			FileName: "test.txt",
			Content:  content,
		}
		body, _ := json.Marshal(uploadReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/file", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusOK, resp.StatusCode)
		mockS3Client.AssertExpectations(t)
	})

	t.Run("s3 fail", func(t *testing.T) {
		content := []byte("file content")
		mockS3Client.On("UploadFile", mock.Anything, "files/test.txt", &content).Return(nil, errors.New("S3 error")).Once()

		uploadReq := req.UploadRequest{
			FileName: "test.txt",
			Content:  content,
		}
		body, _ := json.Marshal(uploadReq)

		req := httptest.NewRequest(http.MethodPost, "/upload/file", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, _ := app.Test(req)
		assert.Equal(t, http.StatusInternalServerError, resp.StatusCode)
		mockS3Client.AssertExpectations(t)
	})
}
