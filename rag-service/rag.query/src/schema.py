from pydantic import BaseModel


class QueryDocument(BaseModel):
    question: str
    session: str
