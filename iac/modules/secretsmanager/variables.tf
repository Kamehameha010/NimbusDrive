variable "secret_name" {
  description = "The name of the secret to create in AWS Secrets Manager"
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the secret to create in AWS Secrets Manager"
  type        = optional(string)
  default     = ""
}

variable "secret_string" {
  description = "The secret string to store in AWS Secrets Manager"
  type        = string
  default     = ""
}
