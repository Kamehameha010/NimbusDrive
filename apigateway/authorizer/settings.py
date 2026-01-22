from pydantic_settings_aws import SecretsManagerBaseSettings


class AWSSecretsSettings(SecretsManagerBaseSettings):
    # 👇 nombre EXACTO del secret en AWS
    secrets_name = "nimbus/supabase"

    # 👇 región donde se crea el secret
    region_name = "us-east-1"

# crear un json "my_secret" con las siguientes claves y valores
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_JWT_SECRET: str


settings = AWSSecretsSettings()
