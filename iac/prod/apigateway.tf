
# API Gateway REST API
resource "aws_api_gateway_rest_api" "apigateway" {
  name        = "NimbusApiGateway"
  description = "API Gateway for Nimbus application"
}

# Authorizer con Lambda Validate
resource "aws_api_gateway_authorizer" "lambda_auth" {
  name                             = "SupabaseAuthorizer"
  rest_api_id                      = aws_api_gateway_rest_api.apigateway.id
  authorizer_uri                   = module.lambda_authorizer_function.lambda_function_invoke_arn
  type                             = "TOKEN"
  identity_source                  = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 120
  authorizer_credentials           = aws_iam_role.invocation_role.arn
}


# # Deploy del API
# resource "aws_api_gateway_deployment" "api_deploy" {
#   depends_on  = []
#   rest_api_id = aws_api_gateway_rest_api.apigateway.id
# }

# resource "aws_api_gateway_stage" "prod" {
#   deployment_id = aws_api_gateway_deployment.api_deploy.id
#   rest_api_id   = aws_api_gateway_rest_api.apigateway.id
#   stage_name    = "prod"
# }

# Permitir que API Gateway invoque el Authorizer
resource "aws_lambda_permission" "allow_apigateway_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_authorizer_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apigateway.execution_arn}/*"
}

# output "apigateway_url" {
#   value = aws_api_gateway_stage.prod.invoke_url
# }