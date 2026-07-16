

output "aws_api_gateway_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "aws_api_gateway_arn" {
  value = aws_api_gateway_rest_api.this.arn
}