data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "api_gateway_auth_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.lambda_authorizer_function.lambda_function_arn]
  }

}


resource "aws_iam_role_policy" "invocation_policy" {
  name   = "default"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

resource "aws_iam_policy" "authorizer_secrets" {
  name = "nimbus-authorizer-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "secretsmanager:GetSecretValue"
      Resource = "${aws_secretsmanager_secret.supabase.arn}*"
    }]
  })
}
