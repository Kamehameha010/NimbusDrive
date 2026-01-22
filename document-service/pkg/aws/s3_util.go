package aws

import (
	"bytes"
	"context"
	"log"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
)

type S3ClientAPI interface {
	UploadFile(ctx context.Context, objectKey string, data *[]byte) (*s3.PutObjectOutput, error)
	CreateMultipartUpload(ctx context.Context, objectKey string) (*s3.CreateMultipartUploadOutput, error)
	UploadPart(ctx context.Context, objectKey string, uploadID string, partNumber int32, data []byte) (*s3.UploadPartOutput, error)
	CompleteMultipartUpload(ctx context.Context, objectKey string, uploadID string, parts []types.CompletedPart) (*s3.CompleteMultipartUploadOutput, error)
	CreatePresignedURL(objectKey string) (string, error)
}

type S3Client struct {
	Client        *s3.Client
	bucketName    string
	region        string
	PresignClient *s3.PresignClient
}

// NewS3Client creates a new S3 client
func NewS3Client(ctx context.Context, bucketName string, region string) (S3ClientAPI, error) {
	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(region))
	if err != nil {
		log.Printf("error loading aws config: %s", err)
		return nil, err
	}

	client := s3.NewFromConfig(cfg)

	presignClient := s3.NewPresignClient(client)

	return &S3Client{
		Client:        client,
		PresignClient: presignClient,
		bucketName:    bucketName,
		region:        region,
	}, nil
}

func (s *S3Client) SetBucketName(bucketName string) {
	s.bucketName = bucketName
}
func (s *S3Client) SetRegion(region string) {
	s.region = region
}

// UploadFile uploads a file to an S3 bucket in a single part.
func (s *S3Client) UploadFile(ctx context.Context, objectKey string, data *[]byte) (*s3.PutObjectOutput, error) {
	input := &s3.PutObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(objectKey),
		Body:   bytes.NewReader(*data),
	}

	return s.Client.PutObject(ctx, input)
}

// CreateMultipartUpload initiates a multipart upload and returns an upload ID.
func (s *S3Client) CreateMultipartUpload(ctx context.Context, objectKey string) (*s3.CreateMultipartUploadOutput, error) {

	input := &s3.CreateMultipartUploadInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(objectKey),
	}
	return s.Client.CreateMultipartUpload(ctx, input)
}

// UploadPart uploads a part in a multipart upload.
func (s *S3Client) UploadPart(ctx context.Context, objectKey string, uploadID string, partNumber int32, data []byte) (*s3.UploadPartOutput, error) {
	input := &s3.UploadPartInput{
		Bucket:     aws.String(s.bucketName),
		Key:        aws.String(objectKey),
		UploadId:   aws.String(uploadID),
		PartNumber: &partNumber,
		Body:       bytes.NewReader(data),
	}
	return s.Client.UploadPart(ctx, input)
}

// CompleteMultipartUpload completes a multipart upload.
func (s *S3Client) CompleteMultipartUpload(ctx context.Context, objectKey string, uploadID string, parts []types.CompletedPart) (*s3.CompleteMultipartUploadOutput, error) {
	input := &s3.CompleteMultipartUploadInput{
		Bucket:   aws.String(s.bucketName),
		Key:      aws.String(objectKey),
		UploadId: aws.String(uploadID),
		MultipartUpload: &types.CompletedMultipartUpload{
			Parts: parts,
		},
	}
	return s.Client.CompleteMultipartUpload(ctx, input)
}

// CreatePresignedURL creates a presigned URL for uploading an object.
// The URL expires in 15 minutes.
func (s *S3Client) CreatePresignedURL(objectKey string) (string, error) {
	presignedUrl, err := s.PresignClient.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(objectKey),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = time.Duration(15 * time.Minute)
	})

	if err != nil {
		log.Printf("Couldn't get a presigned request to put %v to %v. Here's why: %v\n", objectKey, s.bucketName, err)
		return "", err
	}

	return presignedUrl.URL, nil
}
