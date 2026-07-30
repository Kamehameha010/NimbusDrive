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

variable "supabase_url" {
  type      = string
  sensitive = true
}

variable "supabase_anon_key" {
  type      = string
  sensitive = true
}

variable "supabase_jwt_secret" {
  type      = string
  sensitive = true
}


variable "ssm_parameters" {
  type = map(object({
    name        = string
    description = optional(string)
    type        = string
    value       = string
    key_id      = optional(string)
    tags        = optional(map(string))

  }))
  default = {}
}
