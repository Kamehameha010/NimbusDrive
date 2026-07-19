resource "aws_ssm_parameter" "mongo_uri" {
  name   = "/nimbus/app/mongo_uri"
  type   = "SecureString"
  value  = var.mongo_uri
  key_id = data.aws_kms_key.kms_ssm_id.key_id
}

resource "aws_ssm_parameter" "mongodb_dbname" {
  name  = "/nimbus/app/mongodb_dbname"
  type  = "String"
  value = var.mongodb_dbname
}

resource "aws_ssm_parameter" "mongodb_collection" {
  name  = "/nimbus/app/mongodb_collection"
  type  = "String"
  value = var.mongodb_collection
}

resource "aws_ssm_parameter" "mongodb_vector_index" {
  name  = "/nimbus/app/mongodb_vector_index"
  type  = "String"
  value = var.mongodb_vector_index
}

resource "aws_ssm_parameter" "google_api_key" {
  name   = "/nimbus/app/google_api_key"
  type   = "SecureString"
  value  = var.google_api_key
  key_id = data.aws_kms_key.kms_ssm_id.key_id
}

resource "aws_ssm_parameter" "google_model_embedding" {
  name  = "/nimbus/app/google_model_embedding"
  type  = "String"
  value = var.google_model_embedding
}

resource "aws_ssm_parameter" "google_model_chat" {
  name  = "/nimbus/app/google_model_chat"
  type  = "String"
  value = var.google_model_chat
}


# ---------- SUPABASE ----------
resource "aws_ssm_parameter" "supabase_url" {
  name  = "/nimbus/supabase/supabase_url"
  type  = "String"
  value = var.supabase_url
}

resource "aws_ssm_parameter" "supabase_anon_key" {
  name   = "/nimbus/supabase/supabase_anon_key"
  type   = "SecureString"
  value  = var.supabase_anon_key
  key_id = data.aws_kms_key.kms_ssm_id.key_id
}

resource "aws_ssm_parameter" "supabase_jwt_secret" {
  name   = "/nimbus/supabase/jwt_secret"
  type   = "SecureString"
  value  = var.supabase_jwt_secret
  key_id = data.aws_kms_key.kms_ssm_id.key_id
}
