
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]

  }


  create_stage = true

  stage_name = "dev"

  create_domain_name = false

  deploy_stage = true

  # Access logs
  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 7
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }


  # Routes & Integration(s)
  routes = {
    "GET /" = {
      integration = {
        uri                    = module.lambda_function.lambda_function_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "SayHello"
  description   = "My awesome lambda function"
  handler       = "handler.handler"
  runtime       = "python3.13"

  source_path = "../src/MyLambda"

  create_lambda_function_url = true

  tags = {
    Name = "my-lambda1"
  }
}


output "lambda_url" {
  value = module.lambda_function.lambda_function_url
}

output "lambda_id" {
  value = module.lambda_function.lambda_function_arn
}


output "stage_url" {
  value = module.api_gateway.stage_invoke_url
}
