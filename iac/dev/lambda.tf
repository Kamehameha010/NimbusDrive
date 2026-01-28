
module "lambda_authorizer_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "8.1.2"
  function_name = "lambda-authorizer-${random_string.suffix[0].result}"
  description   = "Function for API Gateway authorizer"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"

  source_path = "../../apigateway/authorizer"

  create_lambda_function_url = false
  create_role                = false

  lambda_role = aws_iam_role.lambda_authorizer_role.arn

  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    SECRETS_NAME = aws_secretsmanager_secret.supabase.name
  }

}



module "lambda_vectorize_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "8.1.2"
  function_name = "lambda-vectorize-${random_string.suffix[1].result}"
  description   = "My awesome lambda function"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"

  source_path = "../../rag-service/rag.vectorize"

  create_lambda_function_url = false
  create_role                = false

  lambda_role = aws_iam_role.lambda_vectorize_role.arn

  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    SECRETS_NAME = "aws_secretsmanager_secret.supabase.name"
  }

}

