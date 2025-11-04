from typing import Annotated

from fastapi import Body, Depends, FastAPI, Path
from langchain_mongodb import MongoDBAtlasVectorSearch
from langchain_core.prompts import ChatPromptTemplate
from langchain_google_genai.chat_models import ChatGoogleGenerativeAI
from .schema import QueryDocument
from .vector import get_vector_db
app = FastAPI()


@app.get("/healthy")
def healthy():
    return {
        "message": "Service runinng..."
    }


@app.post("/documents/{doc_id}")
async def analyze_document(
    doc_id: Annotated[Path, str], query: Annotated[QueryDocument, Body],
    db: Annotated[MongoDBAtlasVectorSearch, Depends(get_vector_db)]
):

    chat = ChatGoogleGenerativeAI()

    retriever = db.as_retriever(
        search_type="similarity_score_threshold",
        search_kwargs={"k": 5, "score_threshold": 0.6},
        filter={"doc_id": doc_id}
    )
    relevant_docs = retriever.invoke(query.question)

    prompt = """
    Use the following context to answer the question:

    {context}

    Question: {question}
    Answer the question as accurately as possible. If the answer is not contained within the context, respond with "I don't know."
    Provide a concise and clear answer.
    add the page number at the end of the answer in this format (page number: X).
    """

    chat_prompt_template = ChatPromptTemplate.from_template(prompt)

    context = "\n\n".join([doc.page_content for doc in relevant_docs])

    response = chat.invoke(chat_prompt_template.format_messages(
        context=context, question=query.question))

    return {
        "answer": response.content
    }
