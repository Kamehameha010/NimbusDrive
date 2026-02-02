
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
  handler       = "handler.handler"
  runtime       = "python3.13"

  source_path = "../../rag-service/rag.vectorize"

  create_lambda_function_url = false
  create_role                = false

  lambda_role = aws_iam_role.lambda_vectorize_role.arn

  layers = [
    module.Shared_lambda_layer.lambda_layer_arn
  ]


  environment_variables = {
    SECRETS_NAME = "aws_secretsmanager_secret.supabase.name"
  }

  depends_on = [module.Shared_lambda_layer]

}


module "Shared_lambda_layer" {

  source  = "terraform-aws-modules/lambda/aws"
  version = "8.1.2"

  create_layer = true

  runtime = "python3.13"

  layer_name = "Nimbus-share-layer-${random_string.lambda_suffix[2].id}"

  description = "nimbus share layer"

  compatible_runtimes = ["python3.13"]

  source_path = "../../shared/src/shared"

  build_in_docker = true

  store_on_s3 = true
  s3_bucket   = module.s3_nimbus_share_layer.s3_bucket_id

}
