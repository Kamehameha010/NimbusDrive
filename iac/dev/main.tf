terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = "~> 1.14.0"
}


locals {
  localstack_url = "http://172.16.0.2:4566/"
}


provider "aws" {

  region                      = var.aws_region
  access_key                  = var.aws_access_key_id
  secret_key                  = var.aws_secret_access_key
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    s3              = local.localstack_url
    s3control       = local.localstack_url
    iam             = local.localstack_url
    amplify         = local.localstack_url
    ecs             = local.localstack_url
    lambda          = local.localstack_url
    eventbridge     = local.localstack_url
    apigatewayv2    = local.localstack_url
    apigateway      = local.localstack_url
    cloudwatch      = local.localstack_url
    cloudwatchlogs  = local.localstack_url
    sts             = local.localstack_url
    route53         = local.localstack_url
    route53domains  = local.localstack_url
    route53profiles = local.localstack_url
    route53resolver = local.localstack_url
    kms             = local.localstack_url
    secretsmanager  = local.localstack_url
  }
}

