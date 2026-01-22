# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0]

### Added
- Initial setup for the document-service.
- Basic Fiber server setup.
- Implementing upload handler
- Health checkpoint
- Multipart upload endpoint (`/drive/v1/upload/files/multipart`).
- Endpoint to start a multipart upload (`/drive/v1/upload/files/start`).
- New request models for starting and performing multipart uploads.
- S3 client implementation in `pkg/aws/s3.go` for multipart uploads.
- New handlers for uploading chunks (`UploadChunkHandler`) and completing multipart uploads (`CompleteMultipartUploadHandler`).
- New request and response models to support chunked uploads and completion.
- Health check and compression middleware for improved performance and reliability.

### Changed
- Updated `go.mod` and `go.sum` with new dependencies, including `github.com/bytedance/sonic` for faster JSON serialization.
- Modified `UploadHandler` to support chunked uploads.
- Updated router to include new multipart upload routes.
- Renamed `StartUploadHandler` to `StartMultipartUploadHandler` for clarity.
- Enhanced `main.go` to use `sonic` as the default JSON encoder/decoder, improving performance.

## [0.2.0] - 2026-01-19

### Added
- Unit tests for upload handlers using a mocked S3 client.
- `stretchr/testify` for assertions and mocking in tests.

### Changed
- Refactored `upload_handler.go` to use a structured `UploadHandler` with dependency injection.
- The S3 client is now injected into the handlers, improving testability.
- `main.go` now initializes and injects the S3 client into the router.
- `router.go` accepts the S3 client and sets up routes with the `UploadHandler`.
- `pkg/aws/s3_util.go` now defines an `S3ClientAPI` interface for better abstraction and testing.


