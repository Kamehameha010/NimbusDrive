
module "lambda_authorizer_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "8.1.2"
  function_name = "authorizer-${random_string.random.result}"
  description   = "My awesome lambda function"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"

  source_path = "../apigateway/authorizer"

  create_lambda_function_url = false

  environment_variables = {
    SECRETS_NAME = ""
  }


}



