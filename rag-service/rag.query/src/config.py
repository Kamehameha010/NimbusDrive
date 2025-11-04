from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", env_ignore_empty="ignore"
    )

    mongo_uri: str
    mongo_db: str
    mongo_collection: str
    mongo_vector_index: str

    google_api_key: str


settings = Settings()
