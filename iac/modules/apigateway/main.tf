
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
}


resource "aws_api_gateway_authorizer" "this" {
  count                            = var.create_authorizer ? 1 : 0
  name                             = var.authorizer_config.name
  rest_api_id                      = aws_api_gateway_rest_api.this.id
  authorizer_uri                   = var.authorizer_config.authorizer_uri
  type                             = var.authorizer_config.type
  identity_source                  = var.authorizer_config.identity_source
  authorizer_result_ttl_in_seconds = var.authorizer_config.ttl_in_seconds
  authorizer_credentials           = var.authorizer_config.authorizer_credentials

}


resource "aws_lambda_permission" "this" {
  count         = var.create_authorizer_lambda_permission ? 1 : 0
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_authorizer_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}
