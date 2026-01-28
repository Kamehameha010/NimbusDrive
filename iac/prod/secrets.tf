# resource "aws_secretsmanager_secret" "supabase" {
#   name        = "nimbus/supabase"
#   description = "Supabase secrets for API Gateway authorizer"
# }
# resource "aws_secretsmanager_secret_version" "supabase" {
#   secret_id = aws_secretsmanager_secret.supabase.id

#   secret_string = jsonencode({
#     SUPABASE_URL        = var.supabase_url
#     SUPABASE_ANON_KEY   = var.supabase_anon_key
#     SUPABASE_JWT_SECRET = var.supabase_jwt_secret
#   })
# }
