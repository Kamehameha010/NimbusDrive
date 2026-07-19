# RAG Query Service

> FastAPI service that answers questions about uploaded documents using Retrieval-Augmented Generation (RAG).

Retrieves relevant document chunks from MongoDB Atlas Vector Search, augments the prompt with their content, and generates answers via Google Gemini.

---

## Features

- **Document Q&A** — Ask questions about a specific document
- **Similarity Threshold Retrieval** — k=5, score threshold 0.6
- **Citation Support** — Answers include page numbers
- **Hallucination Guardrails** — Prompt instructs the model to say "I don't know" when uncertain

---

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/documents/{doc_id}` | Query a document |

### Request Body

```json
{
  "question": "What is the main conclusion?",
  "session": "optional-session-id"
}
```

---

## Configuration

Configuration is loaded from AWS SSM Parameter Store under `/nimbus/app/*` via the `shared` library:

- `mongodb_uri`
- `mongodb_dbname`
- `mongodb_collection`
- `mongodb_vector_index`
- `google_api_key`
- `google_model_chat`
- `google_model_embedding`

---

## Quick Start

```bash
cd rag-service/rag.query
uv sync
uv run uvicorn src.main:app --reload
```

---

## Dependencies

- **FastAPI** — REST framework
- **LangChain** — LLM orchestration
- **LangChain Google GenAI** — Gemini integration
- **LangChain MongoDB** — Vector store integration
- **shared** — Common config and vector store utilities
