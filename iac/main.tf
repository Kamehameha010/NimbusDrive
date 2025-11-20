terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = "1.13.4"
}


provider "aws" {

  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    s3               = "http://172.18.0.3:4566"
    iam              = "http://172.18.0.3:4566"
    amplify          = "http://172.18.0.3:4566"
    ecs              = "http://172.18.0.3:4566"
    lambda           = "http://172.18.0.3:4566"
    eventbridge      = "http://172.18.0.3:4566"
    apigatewayv2     = "http://172.18.0.3:4566"
    apigateway       = "http://172.18.0.3:4566"
    cloudwatch       = "http://172.18.0.3:4566"
    cloudwatchlogs   = "http://172.18.0.3:4566"
    cloudwatchlog    = "http://172.18.0.3:4566"
    cloudwatchevents = "http://172.18.0.3:4566"
    events           = "http://172.18.0.3:4566"
    sts              = "http://172.18.0.3:4566"
    route53          = "http://172.18.0.3:4566"
    route53domains   = "http://172.18.0.3:4566"
    route53profiles  = "http://172.18.0.3:4566"
    route53resolver  = "http://172.18.0.3:4566"
    kms              = "http://172.18.0.3:4566"
  }
}

