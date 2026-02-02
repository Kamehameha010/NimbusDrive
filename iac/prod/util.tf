resource "random_string" "lambda_suffix" {
  count   = 10
  length  = 8
  special = false
  upper   = false

}

resource "random_string" "iam_role_suffix" {
  count   = 10
  length  = 8
  special = false
  upper   = false

}


resource "random_string" "s3_bucket_suffix" {
  count   = 10
  length  = 8
  special = false
  upper   = false

}

