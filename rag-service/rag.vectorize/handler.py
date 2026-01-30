from typing import Any, Generator

from langchain_community.document_loaders.s3_file import S3FileLoader
from langchain_community.document_loaders.unstructured import UnstructuredBaseLoader
from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from shared.vector import get_mongodb_client, get_vector_store

client = get_mongodb_client()
vector_store = get_vector_store(client)
vector_store.create_vector_search_index(dimensions=3072)


def handler(event, context):
    bucket_name = event['detail']['bucket']['name']
    object_key = event['detail']['object']['key']
    region = event['region']
    s3loader = S3FileLoader(
        bucket=bucket_name, key=object_key, region_name=region)

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
