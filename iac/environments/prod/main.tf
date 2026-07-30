
locals {
  s3_bucket_suffix = "-ian-${var.aws_region}.s3.com"
  lambda_suffix    = "ian-${var.aws_region}-lambda-com"
  iam_role_suffix  = "ian-${var.aws_region}.iam.com"
}


#region S3 Configuration
module "s3_bucket_files" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.0"

  bucket = "nimbus-drive-${local.s3_bucket_suffix}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
  force_destroy = true

}

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket      = module.s3_bucket_files.s3_bucket_id
#   eventbridge = true

# }

module "s3_bucket_thumbnails" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.0"

  bucket = "nimbus-thumbnails-drive-${local.s3_bucket_suffix}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  force_destroy = true
}


module "s3_notification" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/notification"

  bucket      = module.s3_bucket_files.s3_bucket_id
  eventbridge = true
  lambda_notifications = {
    # lambda_vectorize = {
    #   function_arn  = module.lambda_vectorize_function.lambda_function_arn
    #   function_name = module.lambda_vectorize_function.lambda_function_name
    #   events        = ["s3:ObjectCreated:*"]
    #   filter_prefix = "/"
    #   filter_suffix = ".pdf"
    # }

    lambda_splitter = {
      function_arn  = module.lambda_pdf_splitter_function.lambda_function_arn
      function_name = module.lambda_pdf_splitter_function.lambda_function_name
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "/"
    }
  }

}

#endregion S3 Configuration


#region API GATEWAY Configuration
module "api_gateway" {
  source            = "../../modules/apigateway"
  api_name          = "NimbusApiGateway"
  api_description   = "API Gateway for Nimbus application"
  create_authorizer = true
  authorizer_config = {
    name                   = "SupabaseAuthorizer"
    description            = "Authorizer for Supabase"
    authorizer_uri         = module.lambda_authorizer_function.lambda_function_invoke_arn
    type                   = "TOKEN"
    identity_source        = "method.request.header.Authorization"
    ttl_in_seconds         = 120
    authorizer_credentials = aws_iam_role.invocation_role.arn
  }
  create_authorizer_lambda_permission = true
  lambda_authorizer_function_name     = module.lambda_authorizer_function.lambda_function_name

  api_gateway_resources = {
    success = {
      path_part  = "success"
      parent_key = null
    }
  }
  api_gateway_integrations = {
    success = {
      resource_key    = "success"
      authorization   = "CUSTOM"
      http_method     = "GET"
      integration_uri = module.lambda_vectorize_function.lambda_function_invoke_arn
    }
  }

}
#endregion API GATEWAY Configuration


#region Lambda Configuration
module "lambda_authorizer_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "8.1.2"
  function_name = "lambda-authorizer-${local.lambda_suffix}"
  description   = "Function for API Gateway authorizer"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"

  source_path = "../../lambdas/authorizer"

  create_lambda_function_url = false
  create_role                = false

  lambda_role = aws_iam_role.lambda_authorizer_role.arn

  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    SECRETS_NAME = "aws_secretsmanager_secret.supabase.name"
  }

}

module "lambda_vectorize_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "8.1.2"
  function_name = "lambda-vectorize-${local.lambda_suffix}"
  description   = "Function for vectorizing documents"


  create_package = false

  create_lambda_function_url = false
  create_role                = false

  lambda_role = aws_iam_role.lambda_vectorize_role.arn

  package_type = "Image"

  image_uri = module.docker_build.image_uri



  environment_variables = {
    SECRETS_NAME     = "aws_secretsmanager_secret.supabase.name",
    PYTHONUNBUFFERED = "1"
  }

}

module "docker_build" {

  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  version = "8.1.2"

  create_ecr_repo = true
  ecr_repo        = "nimbus-lambda-vectorize"

  use_image_tag = true
  image_tag     = "1.0"

  source_path      = "${path.module}/../../lambdas"
  docker_file_path = "${path.module}/../../lambdas/rag.vectorize/Dockerfile"

}


module "lambda_pdf_splitter_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "8.1.2"
  function_name = "pdf-splitter${local.lambda_suffix}"
  handler       = "handler.handler"
  runtime       = "python3.13"

  source_path = "../../lambdas/pdfsplitter"

  create_lambda_function_url = false
  create_role                = true
  role_name = "pdf-splitter-role"

  cloudwatch_logs_retention_in_days = 7

}

#endregion Lambda Configuration


#region IAM ROLE
#region IAM ROLE FOR API GATEWAY TO INVOKE LAMBDA AUTHORIZER

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "api_gateway_auth_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.lambda_authorizer_function.lambda_function_arn]
  }

}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "ApiGateway_Invocation_Lambda-${local.iam_role_suffix}"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}
#endregion


#region IAM ROLE FOR LANBADA AUTHORZER TO ACCESS SECRETS MANAGER


data "aws_iam_policy_document" "lambda_authorizer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "authorizer_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
    #resources = [aws_secretsmanager_secret.supabase.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "${module.lambda_authorizer_function.lambda_cloudwatch_log_group_arn}:*",
      "${module.lambda_authorizer_function.lambda_cloudwatch_log_group_arn}:*:*",

    ]
  }

}


resource "aws_iam_role_policy" "authorizer_secrets_attach" {
  name   = "authorizer-policy-${local.iam_role_suffix}"
  role   = aws_iam_role.lambda_authorizer_role.id
  policy = data.aws_iam_policy_document.authorizer_secrets_policy.json
}

resource "aws_iam_role" "lambda_authorizer_role" {
  name               = "lambda-authorizer-${local.iam_role_suffix}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_authorizer_assume_role.json

}

#endregion


#region IAM ROLE FOR LANBADA VECTORIZE


data "aws_iam_policy_document" "lambda_vectorize_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "vectorize_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:us-east-1:*:parameter/nimbus/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "${module.lambda_vectorize_function.lambda_cloudwatch_log_group_arn}:*",
      "${module.lambda_vectorize_function.lambda_cloudwatch_log_group_arn}:*:*",

    ]
  }

}


resource "aws_iam_role_policy" "vectorize_policy" {
  name   = "vectorize-policy-${local.iam_role_suffix}"
  role   = aws_iam_role.lambda_vectorize_role.id
  policy = data.aws_iam_policy_document.vectorize_policy.json
}

resource "aws_iam_role" "lambda_vectorize_role" {
  name               = "vectorize-${local.iam_role_suffix}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_vectorize_assume_role.json

}

#endregion


#endregion IAM ROLE

#region EventBridge Configuration



# module "s3_events" {

#   source  = "terraform-aws-modules/eventbridge/aws"
#   version = "~> 4.3.0"

#   create_bus = false
#   bus_name   = "default"

#   rules = {
#     s3_events = {
#       name        = "s3-new-file-event-rule"
#       description = "Rule to capture S3 events from NimbusDrive buckets"
#       event_pattern = jsonencode({
#         "source" : [
#           "aws.s3"
#         ],

#         "region" : [var.aws_region]

#         "detail-type" : [
#           "Object Created",
#         ],

#         "resources" : [
#           module.s3_bucket_files.s3_bucket_arn
#         ],
#         "detail" : {
#           "bucket" : {
#             "name" : [{
#               "equals-ignore-case" : module.s3_bucket_files.s3_bucket_id
#             }]
#           }
#         }
#       })

#     }

#   }

#   create_role = true
#   role_name   = "Amazon_EventBridge_Invoke_Lambda-${local.iam_role_suffix}"

#   lambda_target_arns   = [module.lambda_vectorize_function.lambda_function_arn]
#   attach_lambda_policy = true


#   targets = {
#     s3_events = [
#       {
#         arn             = module.lambda_vectorize_function.lambda_function_arn
#         name            = "lambda-vectorize"
#         attach_role_arn = true
#       }
#     ]
#   }

# }


#endregion EventBridge Configuration



#region SSM Configuration
module "ssm" {
  source         = "../../modules/ssm"
  environment    = "prod"
  ssm_parameters = var.ssm_parameters
}



#endregion SSM Configuration
