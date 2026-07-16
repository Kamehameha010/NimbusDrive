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
}


module "s3_bucket_files" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = "nimbus-drive-${random_string.s3_bucket_suffix[0].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
  force_destroy = true

}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = module.s3_bucket_files.s3_bucket_id
  eventbridge = true

}

module "s3_bucket_thumbnails" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = "nimbus-thumbnails-drive-${random_string.s3_bucket_suffix[1].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  force_destroy = true
}




module "lambda_authorizer_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "8.1.2"
  function_name = "lambda-authorizer-${random_string.lambda_suffix[0].id}"
  description   = "Function for API Gateway authorizer"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"

  source_path = "../../apigateway/authorizer"

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
  function_name = "lambda-vectorize-${random_string.lambda_suffix[1].id}"
  description   = "Function for vectorizing documents"


  create_package = false

  create_lambda_function_url = false
  create_role                = false

  lambda_role = aws_iam_role.lambda_vectorize_role.arn

  package_type = "Image"

  image_uri = module.docker_build.image_uri



  environment_variables = {
    SECRETS_NAME = "aws_secretsmanager_secret.supabase.name"
  }

}

module "docker_build" {

  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  version = "8.1.2"

  create_ecr_repo = true
  ecr_repo        = "nimbus-lambda-vectorize"

  use_image_tag = true
  image_tag     = "1.0"

  source_path      = "${path.module}/../.."
  docker_file_path = "${path.module}/../../rag-service/rag.vectorize/Dockerfile"

}






module "s3_events" {

  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 4.3.0"

  create_bus = false
  bus_name   = "default"

  rules = {
    s3_events = {
      name        = "s3-new-file-event-rule"
      description = "Rule to capture S3 events from NimbusDrive buckets"
      event_pattern = jsonencode({
        "source" : [
          "aws.s3"
        ],

        "region" : [var.aws_region]

        "detail-type" : [
          "Object Created",
        ],

        "resources" : [
          module.s3_bucket_files.s3_bucket_arn
        ],
        "detail" : {
          "bucket" : {
            "name" : [{
              "equals-ignore-case" : module.s3_bucket_files.s3_bucket_id
            }]
          }
        }
      })

    }

  }

  create_role = true
  role_name   = "Amazon_EventBridge_Invoke_Lambda-${random_string.iam_role_suffix[2].id}"

  lambda_target_arns   = [module.lambda_vectorize_function.lambda_function_arn]
  attach_lambda_policy = true


  targets = {
    s3_events = [
      {
        arn             = module.lambda_vectorize_function.lambda_function_arn
        name            = "lambda-vectorize"
        attach_role_arn = true
      }
    ]
  }

}






