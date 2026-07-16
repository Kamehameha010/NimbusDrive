# Vectorize Lambda

> AWS Lambda function that automatically vectorizes documents uploaded to S3.

Triggered by EventBridge on `Object Created` events. Loads documents, splits them into chunks, generates embeddings via Google Gemini, and stores them in MongoDB Atlas Vector Search.

---

## Pipeline

```
S3 Upload → EventBridge → Lambda → S3FileLoader → Text Splitter → Embeddings → MongoDB Atlas
```

---

## Configuration

Configuration is loaded from AWS SSM Parameter Store under `/nimbus/app/*` via the `shared` library.

---

## Deployment

The Lambda is deployed as a **Docker container image** to Amazon ECR.

```bash
cd iac/prod
terraform apply
```

The `Dockerfile` copies the `shared` library and the handler, then installs dependencies from `requirements.txt`.

---

## Chunking Strategy

| Parameter | Value |
|-----------|-------|
| Chunk size | 520 characters |
| Chunk overlap | 100 characters |
| Embedding model | Google Gemini (3072 dimensions) |

---

## Project Structure

```
rag-service/rag.vectorize/
├── Dockerfile
├── handler.py              # Lambda handler
├── requirements.txt        # Pinned dependencies
├── pyproject.toml
├── .env                    # Local dev environment (gitignored)
├── .gitignore
└── README.md
```
