variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "mongo_uri" {
  type      = string
  sensitive = true
}

variable "mongodb_dbname" {
  type = string
}

variable "mongodb_collection" {
  type = string
}

variable "mongodb_vector_index" {
  type = string
}

variable "google_api_key" {
  type      = string
  sensitive = true
}

variable "google_model_embedding" {
  type = string
}

variable "google_model_chat" {
  type = string
}

variable "supabase_url" {
  type = string
}

variable "supabase_anon_key" {
  type      = string
  sensitive = true
}

variable "supabase_jwt_secret" {
  type      = string
  sensitive = true
}


variable "kms_ssm_id" {
  type = string
}