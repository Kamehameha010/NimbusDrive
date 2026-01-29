
#region IAM ROLE FOR API GATEWAY TO INVOKE LAMBDA AUTHORIZER

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
#endregion


#region IAM ROLE FOR LANBADA AUTHORZER TO ACCESS SECRETS MANAGER


data "aws_iam_policy_document" "lambda_authorizer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "authorizer_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
    #resources = [aws_secretsmanager_secret.supabase.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "${module.lambda_authorizer_function.lambda_cloudwatch_log_group_arn}:*",
      "${module.lambda_authorizer_function.lambda_cloudwatch_log_group_arn}:*:*",

    ]
  }

}


resource "aws_iam_role_policy" "authorizer_secrets_attach" {
  name   = "authorizer-policy-${random_string.suffix[0].result}"
  role   = aws_iam_role.lambda_authorizer_role.id
  policy = data.aws_iam_policy_document.authorizer_secrets_policy.json
}

resource "aws_iam_role" "lambda_authorizer_role" {
  name               = "autthorizer-${random_string.suffix[0].result}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_authorizer_assume_role.json

}

#endregion


#region IAM ROLE FOR LANBADA VECTORIZE


data "aws_iam_policy_document" "lambda_vectorize_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "vectorize_policy" {
statement {
  effect = "Allow"
  actions = [
    "ssm:GetParameter",
    "ssm:GetParameters",
    "ssm:GetParametersByPath"
  ]
  resources = [
    "arn:aws:ssm:us-east-1:*:parameter/nimbus/*"
  ]
}
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "${module.lambda_vectorize_function.lambda_cloudwatch_log_group_arn}:*",
      "${module.lambda_vectorize_function.lambda_cloudwatch_log_group_arn}:*:*",

    ]
  }

}


resource "aws_iam_role_policy" "vectorize_policy" {
  name   = "vectorize-policy-${random_string.suffix[1].result}"
  role   = aws_iam_role.lambda_vectorize_role.id
  policy = data.aws_iam_policy_document.vectorize_policy.json
}

resource "aws_iam_role" "lambda_vectorize_role" {
  name               = "vectorize-${random_string.suffix[1].result}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_vectorize_assume_role.json

}

#endregion


#region IAM ROLE FOR EVENTBRIDGE TO INVOKE LAMBDA

data "aws_iam_policy_document" "eventbridge_invoke_vectorize_policy" {

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
     module.lambda_vectorize_function.lambda_function_arn
    ]
  }

}


resource "aws_iam_role_policy" "eventbridge_invoke_vectorize_policy" {
  name   = "Amazon_EventBridge_Invoke_Lambda_-${random_string.suffix[3].result}"
  role   = module.s3_events.eventbridge_role_name
  policy = data.aws_iam_policy_document.eventbridge_invoke_vectorize_policy.json
}

#endregion