
variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = ""
}

variable "api_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = ""
}

variable "create_authorizer" {
  description = "Whether to create the API Gateway authorizer"
  type        = bool
  default     = false
}

variable "authorizer_config" {
  description = "The configuration for the API Gateway authorizer"
  type = object({
    name                   = string
    description            = optional(string)
    authorizer_uri         = string
    type                   = string
    identity_source        = string
    ttl_in_seconds         = number
    authorizer_credentials = string
  })
  default = {
    name                   = ""
    description            = ""
    authorizer_uri         = ""
    type                   = ""
    identity_source        = ""
    ttl_in_seconds         = 60
    authorizer_credentials = ""
  }
}

variable "create_authorizer_lambda_permission" {
  description = "Whether to create the Lambda permission for the API Gateway authorizer"
  type        = bool
  default     = false
}

variable "lambda_authorizer_function_name" {
  description = "The name of the Lambda function to be used as the authorizer"
  type        = string
  default     = ""
}

variable "stages" {
  description = "A map of stages to be created for the API Gateway"
  type        = list(string)
  default     = []
}


variable "api_gateway_resources" {
  description = "A map of API Gateway resources to be created"
  type = map(object({
    path_part  = string
    parent_key = optional(string)

  }))
  default = {}
}

variable "api_gateway_integrations" {
  description = "A map of API Gateway integrations to be created"
  type = map(object({
    resource_key       = string
    http_method        = string
    authorization      = optional(string, "NONE")
    integration_type   = optional(string, "AWS_PROXY")
    integration_uri    = string
    connection_type    = optional(string)
    connection_id      = optional(string)
    integration_target = optional(string)
  }))
  default = {}
}
