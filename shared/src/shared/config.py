import os
from typing import Annotated

from pydantic_settings import SettingsConfigDict
from pydantic_settings_aws import ParameterStoreBaseSettings


class AppSettings(ParameterStoreBaseSettings):

    model_config = SettingsConfigDict(
        aws_region=os.getenv("AWS_REGION", "us-east-1"),
    )

    mongodb_uri: Annotated[str, "/nimbus/app/mongo_uri"]
    mongodb_dbname: Annotated[str, "/nimbus/app/mongodb_dbname"]
    mongodb_collection: Annotated[str, "/nimbus/app/mongodb_collection"]
    mongodb_vector_index: Annotated[str, "/nimbus/app/mongodb_vector_index"]

    google_api_key: Annotated[str, "/nimbus/app/google_api_key"]
    google_model_embedding: Annotated[str,
                                      "/nimbus/app/google_model_embedding"]
    google_model_chat: Annotated[str, "/nimbus/app/google_model_chat"]


class SupaBaseSettings(ParameterStoreBaseSettings):

    model_config = SettingsConfigDict(
        aws_region=os.getenv("AWS_REGION", "us-east-1")
    )
    supabase_url: Annotated[str, "/nimbus/supabase/supabase_url"]
    supabase_anon_key: Annotated[str, "/nimbus/supabase/supabase_anon_key"]
    supabase_jwt_secret: Annotated[str, "/nimbus/supabase/jwt_secret"]


app_settings = AppSettings()
supabase_settings = SupaBaseSettings()
