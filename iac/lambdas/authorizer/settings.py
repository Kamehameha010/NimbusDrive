import os
from typing import Annotated

from pydantic_settings import SettingsConfigDict
from pydantic_settings_aws import ParameterStoreBaseSettings


class SupaBaseSettings(ParameterStoreBaseSettings):

    model_config = SettingsConfigDict(
        aws_region=os.getenv("AWS_REGION")
    )
    supabase_url: Annotated[str, "/nimbus/supabase/supabase_url"]
    supabase_anon_key: Annotated[str, "/nimbus/supabase/supabase_anon_key"]
    supabase_jwt_secret: Annotated[str, "/nimbus/supabase/jwt_secret"]
