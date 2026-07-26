
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
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/authorizers/*"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_authorizer.this,
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this
  ]
}

resource "aws_api_gateway_stage" "this" {
  count         = length(var.stages)
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stages[count.index]
}


resource "aws_api_gateway_method" "this" {
  for_each      = var.api_gateway_integrations
  http_method   = each.value.http_method
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.value.resource_key].id
  authorization = each.value.authorization
  authorizer_id = each.value.authorization == "CUSTOM" ? (
    var.create_authorizer ? aws_api_gateway_authorizer.this[0].id : try(each.value.authorizer_id, null)
  ) : null
}

resource "aws_api_gateway_resource" "this" {
  for_each    = var.api_gateway_resources
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = each.value.parent_key != null ? aws_api_gateway_resource.this[each.value.parent_key].id : aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}


resource "aws_api_gateway_integration" "this" {
  for_each                = var.api_gateway_integrations
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this[each.value.resource_key].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = each.value.integration_type == "AWS_PROXY" ? "POST" : each.value.http_method
  type                    = each.value.integration_type
  uri                     = each.value.integration_uri
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_type == "VPC_LINK" ? each.value.vpc_link_id : null

  integration_target = try(each.value.integration_target, null)

}
