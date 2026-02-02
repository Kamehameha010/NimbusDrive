module "s3_bucket_files" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = "nimbus-drive-${random_string.s3_bucket_suffix[0].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  force_destroy = true


}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = module.s3_bucket_files.s3_bucket_id
  eventbridge = true

}


module "s3_bucket_thumbnails" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = "nimbus-thumbnails-drive-${random_string.s3_bucket_suffix[1].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  force_destroy = true
}


module "s3_nimbus_share_layer" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = "nimbus-layers-${random_string.s3_bucket_suffix[2].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
  force_destroy = true
}
