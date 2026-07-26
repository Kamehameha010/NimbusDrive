output "ssm_id" {
  value = {for k, v in aws_ssm_parameter.this : k => v.id}
}

output "ssm_name" {
  value = {for k, v in aws_ssm_parameter.this : k => v.name}
}

output "ssm_arn" {
  value = {for k, v in aws_ssm_parameter.this : k => v.arn}
}
output "ssm_version" {
  value = {for k, v in aws_ssm_parameter.this : k => v.version}
}

output "ssm_kms_key_id" {
  value = {for k, v in aws_ssm_parameter.this : k => v.key_id}
}
