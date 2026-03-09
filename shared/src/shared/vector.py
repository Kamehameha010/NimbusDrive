from contextlib import contextmanager
from typing import Generator

from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_mongodb import MongoDBAtlasVectorSearch
from pymongo import MongoClient

from .config import app_settings


def get_mongodb_client() -> MongoClient:
    return MongoClient(app_settings.mongodb_uri)


def get_embeddings() -> GoogleGenerativeAIEmbeddings:
    return GoogleGenerativeAIEmbeddings(
        model=app_settings.google_model_embedding,
        api_key=app_settings.google_api_key
        )


def get_vector_store(client: MongoClient) -> MongoDBAtlasVectorSearch:
    db = client[app_settings.mongodb_dbname]
    collection = db[app_settings.mongodb_collection]

    return MongoDBAtlasVectorSearch(
        collection=collection,
        embedding=get_embeddings(),
        index_name=app_settings.mongodb_vector_index,
        relevance_score_fn="cosine",
    )


@contextmanager
def get_vector_db() -> Generator[MongoDBAtlasVectorSearch, None, None]:
    client = get_mongodb_client()
    vector_store = get_vector_store(client)
    try:
        yield vector_store
    finally:
        client.close()
