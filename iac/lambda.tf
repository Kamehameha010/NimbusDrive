# Lambda Validate (Authorizer)
resource "aws_lambda_function" "authorizer" {
  function_name = "authorizer"
  handler       = "supabase_authorizer.handler"
  runtime       = "python3.13"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "${path.module}/lambda/validate.zip"

  environment {
    variables = {
      SECRETS_NAME= ""
    }
  }
}

