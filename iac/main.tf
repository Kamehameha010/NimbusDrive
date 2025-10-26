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
    s3          = "http://localhost:4566"
    iam         = "http://localhost:4566"
    amplify     = "http://localhost:4566"
    ecs         = "http://localhost:4566"
    lambda      = "http://localhost:4566"
    eventbridge = "http://localhost:4566"
  }
}

