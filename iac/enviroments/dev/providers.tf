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
