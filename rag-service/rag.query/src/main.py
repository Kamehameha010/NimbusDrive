from typing import Annotated

from fastapi import Body, FastAPI, Path

from .schema import QueryDocument

app = FastAPI()


@app.get("/healthy")
def healthy():
    return {
        "message": "Service runinng..."
    }

@app.post("/documents/{doc_id}")
async def analyze_document(
    doc_id: Annotated[Path, str], query: Annotated[QueryDocument, Body]
): ...
