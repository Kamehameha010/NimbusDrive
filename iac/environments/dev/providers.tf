locals {
  localstack_url = "http://172.16.0.2:4566/"
}


provider "aws" {

  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

}


data "aws_ecr_authorization_token" "token" {}


provider "docker" {

  registry_auth {
    address  = "000000000000.dkr.ecr.us-east-1.localhost:5100"
    username = "AWS"
    password = "000000000000.dkr.ecr.us-east-1.localhost:5100"
  }

}
