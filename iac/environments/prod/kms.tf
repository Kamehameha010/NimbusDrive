

data "aws_kms_key" "kms_ssm_id" {
  key_id = var.kms_ssm_id
}