# Shared Library

> Python package with common configuration and vector store utilities shared across NimbusDrive services.

---

## Modules

### `config.py`

Configuration models using `pydantic-settings-aws` to read from AWS SSM Parameter Store.

**`AppSettings`** — Application settings under `/nimbus/app/*`:
- `mongodb_uri`, `mongodb_dbname`, `mongodb_collection`, `mongodb_vector_index`
- `google_api_key`, `google_model_embedding`, `google_model_chat`

**`SupaBaseSettings`** — Supabase settings under `/nimbus/supabase/*`:
- `supabase_url`, `supabase_anon_key`, `supabase_jwt_secret`

Settings are instantiated as module-level singletons for easy import.

### `vector.py`

Utilities for MongoDB Atlas Vector Search:

- `get_mongodb_client()` — Returns a `MongoClient` instance
- `get_embeddings()` — Returns a `GoogleGenerativeAIEmbeddings` instance
- `get_vector_store(client)` — Returns a `MongoDBAtlasVectorSearch` configured with embeddings
- `get_vector_db()` — Context manager yielding a ready-to-use vector store

---

## Installation

This package is installed as a local dependency via `uv`:

```toml
# In pyproject.toml
[tool.uv.sources]
shared = { path = "../../shared" }
```

### Optional dependency groups

| Group | Includes |
|-------|----------|
| `unstructured` | Document parsing (PDF, DOCX, MD) |
| `langchain` | LangChain + Google GenAI + MongoDB integration |
| `all` | Everything above |

```bash
uv sync --extra all
```

---

## Project Structure

```
shared/
├── src/
│   └── shared/
│       ├── __init__.py
│       ├── config.py
│       ├── vector.py
│       └── py.typed
├── pyproject.toml
└── README.md
```
