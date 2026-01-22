package handlers

import (
	"context"
	"fmt"
	req "nimbus-document-upload-service/internal/models/requests"
	"nimbus-document-upload-service/pkg/aws"

	"github.com/aws/aws-sdk-go-v2/service/s3/types"

	"github.com/gofiber/fiber/v2"
)

var (
	basePath = "files"
)

type UploadHandler struct {
	s3Client aws.S3ClientAPI
}

func NewUploadHandler(s3Client aws.S3ClientAPI) *UploadHandler {
	return &UploadHandler{
		s3Client: s3Client,
	}
}

func (h *UploadHandler) StartMultipartUploadHandler(c *fiber.Ctx) error {

	startRequestPayload := new(req.StartUploadRequest)

	if err := c.BodyParser(&startRequestPayload); err != nil {
		return c.Status(fiber.ErrBadRequest.Code).JSON(fiber.Map{
			"error":  "Failed to parse upload request",
			"detail": err.Error(),
		})
	}

	ctx := context.TODO()

	objectKey := fmt.Sprintf("%s/%s", basePath, startRequestPayload.FileName)

	response, err := h.s3Client.CreateMultipartUpload(ctx, objectKey)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "Failed to start multipart upload",
			"detail": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"upload_id": *response.UploadId,
		"filename":  startRequestPayload.FileName,
		"status":    "started",
	})
}

func (h *UploadHandler) UploadChunkHandler(c *fiber.Ctx) error {

	uploadChunkRequest := new(req.UploadChunkRequest)
	if err := c.BodyParser(uploadChunkRequest); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":  "Failed to parse upload chunk request",
			"detail": err.Error(),
		})
	}

	if len(uploadChunkRequest.ChunkContent) > 10*1024*1024 { // 10 MB limit
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "ChunkContent exceeds the maximum allowed size of 10MB",
		})
	}

	if uploadChunkRequest.FileName == "" || uploadChunkRequest.UploadID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "FileName and UploadID are required",
		})
	}

	objectKey := fmt.Sprintf("%s/%s", basePath, uploadChunkRequest.FileName)

	_, err := h.s3Client.UploadPart(c.Context(), objectKey, uploadChunkRequest.UploadID, uploadChunkRequest.ChunkNumber, uploadChunkRequest.ChunkContent)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "Failed to upload part",
			"detail": err.Error(),
		})
	}

	return c.Status(fiber.StatusAccepted).JSON(fiber.Map{
		"message": "Chunk uploaded successfully",
	})
}

func (h *UploadHandler) CompleteMultipartUploadHandler(c *fiber.Ctx) error {

	uploadCompleteRequest := new(req.UploadCompleteRequest)
	if err := c.BodyParser(uploadCompleteRequest); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":  "Failed to parse upload complete request",
			"detail": err.Error(),
		})
	}

	if uploadCompleteRequest.FileName == "" || uploadCompleteRequest.UploadID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "FileName and UploadID are required",
		})
	}

	objectKey := fmt.Sprintf("%s/%s", basePath, uploadCompleteRequest.FileName)

	parts := make([]types.CompletedPart, len(uploadCompleteRequest.PartETags))

	for i, part := range uploadCompleteRequest.PartETags {
		parts[i] = types.CompletedPart{
			ETag:       &part.ETag,
			PartNumber: &part.PartNumber,
		}
	}

	_, err := h.s3Client.CompleteMultipartUpload(c.Context(), objectKey, uploadCompleteRequest.UploadID, parts)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "Failed to complete multipart upload",
			"detail": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "Upload completed successfully",
	})
}

func (h *UploadHandler) UploadFileHandler(c *fiber.Ctx) error {

	uploadRequest := new(req.UploadRequest)
	if err := c.BodyParser(uploadRequest); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":  "Failed to parse upload request",
			"detail": err.Error(),
		})
	}

	if len(uploadRequest.Content) > 10*1024*1024 { // 10 MB limit
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "File exceeds the maximum allowed size of 10MB",
		})
	}

	if uploadRequest.FileName == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "FileName and FolderId are required",
		})

	}

	objectKey := fmt.Sprintf("%s/%s", basePath, uploadRequest.FileName)
	_, err := h.s3Client.UploadFile(c.Context(), objectKey, &uploadRequest.Content)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":  "Failed to upload file",
			"detail": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "File uploaded successfully",
	})
}
