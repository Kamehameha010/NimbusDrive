
module "lambda_authorizer_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "authorizer"
  description   = "My awesome lambda function"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"

  source_path = "../apigateway/authorizer"

  create_lambda_function_url = false

  environment_variables = {
    SECRETS_NAME= ""
  }

}
