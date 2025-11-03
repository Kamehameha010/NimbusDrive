from pydantic import BaseModel


class QueryDocument(BaseModel):
    query: str
    session: str
