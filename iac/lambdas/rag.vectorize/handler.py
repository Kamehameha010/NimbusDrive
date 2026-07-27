import logging
from collections.abc import Generator
from typing import Any

from langchain_community.document_loaders.s3_file import S3FileLoader
from langchain_community.document_loaders.unstructured import UnstructuredBaseLoader
from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from shared.vector import get_mongodb_client, get_vector_store

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler())

try:

    client = get_mongodb_client()
    vector_store = get_vector_store(client)
    vector_store.create_vector_search_index(dimensions=3072)
except Exception as e:
    logger.error(f"Error initializing vector store: {e}")

def handler(event, context):
    bucket_name = event['detail']['bucket']['name']
    object_key = event['detail']['object']['key']
    region = event['region']
    logger.info(f"Received event for bucket: {bucket_name}, object: {object_key}, region: {region}")

    s3loader = S3FileLoader(
        bucket=bucket_name, key=object_key, region_name=region)

    logger.info(f"Initialized S3FileLoader for bucket: {bucket_name}, key: {object_key}, region: {region}")
    doc_loaded = load_doc(s3loader, {})
    
    logger.info(f"Loading document from S3 using S3FileLoader for bucket: {bucket_name}, key: {object_key}")
    
    logger.info(f"Loaded document from S3: {doc_loaded}")

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=520, chunk_overlap=100)
    
    logger.info("Splitting document into chunks with chunk size 520 and chunk overlap 100")

    docs = splitter.split_documents(doc_loaded)
    logger.info(f"Split document into {len(docs)} chunks")

    vector_store.add_documents(docs)
    logger.info(f"Added documents to vector store: {docs}")

    # region TODO
    # update database
    # endregion

    return {"status": 200, "body": ""}


def load_doc(
    loader: UnstructuredBaseLoader, extra_metadata: dict[str, Any] | None = None
) -> Generator[Document, tuple[UnstructuredBaseLoader, dict], None]:
    if extra_metadata is None:
        yield from loader.lazy_load()
        return

    for page in loader.lazy_load():
        page.metadata.update(**extra_metadata)
        yield page
