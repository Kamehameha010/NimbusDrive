locals {
  available_environments = ["dev", "staging", "prod"]
}

variable "environment" {
  description = "The environment for the SSM module (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains([for e in local.available_environments : lower(e)], lower(var.environment))
    error_message = "Invalid environment. Must be one of: ${join(", ", local.available_environments)}"
  }
}


variable "ssm_parameters" {

  description = "A map of SSM parameters to create. Each parameter is defined as an object with the following attributes: name, description (optional), type, value, key_id (optional), and tags (optional)."
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
