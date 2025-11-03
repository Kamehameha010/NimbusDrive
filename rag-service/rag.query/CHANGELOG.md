...existing code...
# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-11-02
### Added
- Initial configuration for the RAG query service:
  - FastAPI scaffold with query endpoint and health check.
  - Basic logging and CORS configuration.
- Settings file implemented using Pydantic with environment-variable support and validation.
- Query schema implemented (src/schema.py):
  - QueryDocument Pydantic model with fields: `query: str`, `session: str`.

### Changed
- Update devcontainer settings

