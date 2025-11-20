
# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "SupabaseAuthAPI"
  description = "API Gateway con authorizer Supabase"
}

# Authorizer con Lambda Validate
resource "aws_api_gateway_authorizer" "lambda_auth" {
  name                         = "SupabaseAuthorizer"
  rest_api_id                  = aws_api_gateway_rest_api.api.id
  authorizer_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.validate.invoke_arn}/invocations"
  type                         = "TOKEN"
  identity_source              = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 0 
}

# Deploy del API
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

# Permitir que API Gateway invoque el Authorizer
resource "aws_lambda_permission" "allow_apigateway_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validate.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

