

resource "aws_ssm_parameter" "this" {
  for_each    = var.ssm_parameters
  name        = "/${var.environment}/${each.value.name}"
  description = try(each.value.description, null)
  type        = each.value.type
  value       = each.value.value
  tags        = try(each.value.tags, null)
  key_id      = try(each.value.key_id, null)
}
