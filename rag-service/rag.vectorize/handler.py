import os
from typing import Any, Generator

from langchain_community.document_loaders.s3_file import S3FileLoader
from langchain_community.document_loaders.unstructured import UnstructuredBaseLoader
from langchain_core.documents import Document
from langchain_google_genai.embeddings import GoogleGenerativeAIEmbeddings
from langchain_mongodb import MongoDBAtlasVectorSearch
from langchain_text_splitters import RecursiveCharacterTextSplitter
from pymongo import MongoClient

embeddings = GoogleGenerativeAIEmbeddings(model="models/gemini-embedding-001")

client = MongoClient(os.getenv("MONGODB_URI"))
db = client[os.getenv("MONGODB_DB")]
collection = db[os.getenv("MONGODB_COLLECTION")]
atlas_vector_search_index = os.getenv("MONGODB_VECTOR_INDEX")


vector_store = MongoDBAtlasVectorSearch(
    collection=collection,
    embedding=embeddings,
    index_name=atlas_vector_search_index,
    relevance_score_fn="cosine",
)
vector_store.create_vector_search_index(dimensions=3072)


def handler(event, context):
    s3loader = S3FileLoader(bucket="", key="", region_name="", endpoint_url="")

    doc_loaded = load_doc(s3loader, {})

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=520, chunk_overlap=100)

    docs = splitter.split_documents(doc_loaded)

    vector_store.add_documents(docs)

    # region TODO
    # update database
    # endregion

    return {"status": 200, "body": ""}


def load_doc(
    loader: UnstructuredBaseLoader, extra_metadata: dict[str, Any] | None = None
) -> Generator[Document, tuple[UnstructuredBaseLoader, dict], None]:
    if extra_metadata is None:
        yield from loader.lazy_load()

    for page in loader.lazy_load():
        page.metadata.update(**extra_metadata)
        yield page
