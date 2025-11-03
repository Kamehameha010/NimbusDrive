from contextlib import contextmanager
from typing import Generator

from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_mongodb import MongoDBAtlasVectorSearch
from pymongo import MongoClient

from .config import settings


@contextmanager
def get_vector_db() -> Generator:
    client = MongoClient(settings.mongo_uri)
    db = client[settings.mongo_db]
    collection = db[settings.mongo_collection]

    embedding = GoogleGenerativeAIEmbeddings(
        model="models/gemini-embedding-001")

    vector_store = MongoDBAtlasVectorSearch(
        collection=collection,
        embedding=embedding,
        index_name=settings.mongo_vector_index,
        relevance_score_fn="cosine",
    )

    try:
        yield vector_store
    finally:
        vector_store.close()
