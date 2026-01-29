variable "mongo_uri" {
  type      = SecureString
  sensitive = true
}

variable "mongodb_dbname" {
  type      = string
}

variable "mongodb_collection" {
  type      = string
}

variable "mongodb_vector_index" {
  type      = string
}

variable "google_api_key" {
  type      = SecureString
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
  type      = SecureString
  sensitive = true
}

variable "supabase_jwt_secret" {
  type      = SecureString
  sensitive = true
}
