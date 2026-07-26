output "secret_name" {
  value = aws_secretsmanager_secret.this.name
}
output "secret_id" {
  value = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}

output "secret_version_id" {
  value = aws_secretsmanager_secret_version.this.version_id
}


output "secret_string" {
  value = aws_secretsmanager_secret_version.this.secret_string
}

output "secret_kms_key_id" {
  value = aws_secretsmanager_secret.this.kms_key_id
}