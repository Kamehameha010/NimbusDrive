
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

  version         = "8.1.2"
  
  create_ecr_repo = true
  ecr_repo        = "nimbus-lambda-vectorize"

  use_image_tag = true
  image_tag     = "1.0"

  source_path = "${path.module}/../.."
  docker_file_path = "${path.module}/../../rag-service/rag.vectorize/Dockerfile"

}
