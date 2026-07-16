# Document Service

> Go/Fiber REST API for file uploads to AWS S3. Supports single-part and multi-part (chunked) uploads.

---

## Features

- **Single-part upload** — Up to 10 MB per request
- **Multi-part upload** — Start / chunk / complete workflow (10 MB per chunk)
- **Presigned URLs** — Time-limited direct upload URLs (15 min expiry)
- **Dual configuration source** — `.env` file or AWS Secrets Manager
- **Sonic JSON** — High-performance JSON encoding/decoding
- **Health check** — Readiness endpoint

---

## Endpoints

All endpoints are prefixed with `/drive/v1/`.

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/upload/files` | Single-part file upload |
| `POST` | `/upload/files/start` | Initiate a multipart upload |
| `PUT` | `/upload/files/multipart` | Upload a chunk |
| `PUT` | `/upload/files/completed` | Complete a multipart upload |

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `APP_PORT` | Yes | — | Server port |
| `AWS_S3_BUCKET_NAME` | Yes | — | S3 bucket for file storage |
| `AWS_REGION` | No | `us-east-1` | AWS region |
| `CONFIG_SOURCE` | No | — | Set to `AWS` to read config from Secrets Manager |

### Supabase Config

See `pkg/config.go`. Config can be loaded from a `.env` file or AWS Secrets Manager (controlled by `CONFIG_SOURCE`).

---

## Quick Start

```bash
# Install dependencies
go mod download

# Run
APP_PORT=8080 AWS_S3_BUCKET_NAME=nimbus-drive go run cmd/api/main.go
```

---

## Testing

```bash
go test ./... -v
```

Tests use a `MockS3Client` (via `testify/mock`) to avoid real AWS calls. Each handler is tested for success and S3 failure scenarios.

---

## Project Structure

```
document-service/
├── cmd/api/main.go              # Entry point
├── internal/
│   ├── handlers/                # HTTP handlers
│   │   └── upload_handler.go
│   ├── models/                  # Request/response types
│   │   ├── requests/
│   │   └── responses/
│   └── router/                  # Route definitions
│       └── router.go
├── pkg/
│   ├── aws/
│   │   └── s3_util.go           # S3 client + interface
│   ├── config.go                # Configuration loader
│   └── supabase.go              # Supabase client
└── tests/
    └── handlers_test/
        └── upload_handler_test.go
```
