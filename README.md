# NimbusDrive

> Cloud-native document management system with AI-powered RAG (Retrieval-Augmented Generation).

NimbusDrive is a serverless document storage and Q&A platform. Upload files via a Go/Fiber API into AWS S3, automatically vectorize them through an event-driven pipeline (EventBridge → Lambda → MongoDB Atlas), and ask questions about their content using Google Gemini.

---

## Architecture

```
                           ┌─────────────────┐
                           │   Nimbus UI     │
                           │  (Preact + Vite)│
                           └────────┬────────┘
                                    │ HTTP
                           ┌────────▼────────┐
                           │   API Gateway   │
                           │  (+ Authorizer) │
                           └────────┬────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │                               │
           ┌────────▼────────┐            ┌─────────▼──────────┐
           │ Document Service│            │  Lambda Authorizer │
           │   (Go / Fiber)  │            │  (Python / JWT)    │
           └────────┬────────┘            └────────────────────┘
                    │ PUT/GET
           ┌────────▼────────┐
           │    AWS S3       │
           │  (file store)   │
           └────────┬────────┘
                    │ Object Created
           ┌────────▼────────┐
           │   EventBridge   │
           └────────┬────────┘
                    │
           ┌────────▼────────┐
           │  Vectorize Lambda│
           │  (Python/LangChain)
           └────────┬────────┘
                    │ embeddings
           ┌────────▼────────┐
           │  MongoDB Atlas  │
           │ (Vector Search) │
           └────────┬────────┘
                    │ query
           ┌────────▼────────┐
           │   RAG Query     │
           │  (FastAPI)      │
           └─────────────────┘
```

---

## Services

| Service | Location | Stack | Description |
|---------|----------|-------|-------------|
| **Nimbus UI** | `nimbus-ui/` | Preact + Rolldown-Vite | Frontend application |
| **Document Service** | `document-service/` | Go + Fiber + AWS SDK | File upload API (single & multipart) |
| **RAG Query** | `iac/lambdas/rag.query/` | Python + FastAPI + LangChain | Q&A interface over vectorized documents |
| **Vectorize Lambda** | `iac/lambdas/rag.vectorize/` | Python + LangChain + Unstructured | Event-driven document vectorization |
| **Authorizer** | `iac/lambdas/authorizer/` | Python + PyJWT | Supabase JWT validation for API Gateway |
| **Shared Library** | `iac/lambdas/shared/` | Python | Common config and vector store utilities |
| **Infrastructure** | `iac/` | Terraform | AWS infrastructure (dev + prod) |

---

## Features

- **Multi-part File Upload** — Chunked uploads to S3 (10 MB per chunk)
- **Single-part File Upload** — Simple file upload to S3 (10 MB limit)
- **Presigned URLs** — Time-limited direct upload URLs (15 min expiry)
- **S3 Versioning** — Object versioning enabled on file buckets
- **JWT Authentication** — Supabase token validation (HS256 + RS256/JWKS)
- **Event-Driven Vectorization** — Automatic document processing on S3 upload
- **RAG Question Answering** — Ask questions and get answers with page citations
- **Infrastructure as Code** — Full Terraform config for dev (LocalStack) and prod (AWS)

---

## Prerequisites

- [Go](https://go.dev/) 1.25+
- [Python](https://www.python.org/) 3.13+
- [Node.js](https://nodejs.org/) 24+
- [pnpm](https://pnpm.io/)
- [uv](https://docs.astral.sh/uv/)
- [Terraform](https://www.terraform.io/) ~> 1.14.0
- [Docker](https://www.docker.com/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [LocalStack](https://www.localstack.cloud/) (for dev)

---

## Getting Started (Development)

### 1. Clone the repository

```bash
git clone <repo-url>
cd NimbusDrive
```

### 2. Infrastructure (dev with LocalStack)

```bash
cd iac/environments/dev
terraform init
terraform plan
terraform apply
```

### 3. Document Service

```bash
cd document-service
go mod download
APP_PORT=8080 AWS_S3_BUCKET_NAME=nimbus-drive AWS_REGION=us-east-1 go run cmd/api/main.go
```

### 4. RAG Query Service

```bash
cd iac/lambdas/rag.query
uv sync
uv run uvicorn src.main:app --reload
```

### 5. Frontend

```bash
cd nimbus-ui
pnpm install
pnpm dev
```

---

## Environment Variables

| Variable | Service | Description |
|----------|---------|-------------|
| `APP_PORT` | Document Service | Server port (default: `8080`) |
| `AWS_S3_BUCKET_NAME` | Document Service | S3 bucket name for file storage |
| `AWS_REGION` | All | AWS region (default: `us-east-1`) |
| `GOOGLE_API_KEY` | RAG Services | Google Generative AI API key |
| `CONFIG_SOURCE` | Document Service | `AWS` for Secrets Manager, otherwise `.env` |

Secrets are managed via AWS SSM Parameter Store under `/nimbus/app/*` and `/nimbus/supabase/*`.

---

## Project Structure

```
NimbusDrive/
├── docs/                      # Architecture diagram, analysis, checklist
├── document-service/          # Go/Fiber API for file uploads
│   ├── cmd/api/main.go
│   ├── internal/
│   ├── pkg/
│   └── tests/
├── iac/                       # Terraform infrastructure
│   ├── environments/
│   │   ├── dev/               # LocalStack environment
│   │   └── prod/              # AWS production environment
│   ├── lambdas/
│   │   ├── authorizer/        # Lambda authorizer (JWT validation)
│   │   ├── rag.query/         # FastAPI RAG query service
│   │   ├── rag.vectorize/     # Lambda for document vectorization
│   │   └── shared/            # Shared Python library
│   └── modules/
│       ├── apigateway/
│       ├── secretsmanager/
│       └── ssm/
├── nimbus-ui/                 # Preact frontend
│   └── src/
├── scripts/                   # Utility scripts
└── .devcontainer/             # VS Code dev container configs
```

---

## Testing

```bash
# Document Service
cd document-service
go test ./... -v
```

Tests are only implemented in the Document Service currently. Contributions welcome.

---

## Deployment

Deploy to production with Terraform:

```bash
cd iac/environments/prod
terraform init
terraform plan
terraform apply
```

The vectorize Lambda is built as a Docker image and pushed to Amazon ECR.

---

## License

[MIT](LICENSE)
