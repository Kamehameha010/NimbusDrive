module "s3_bucket_files" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "nimbus-drive"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}


module "s3_bucket_thumbnails" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "nimbus-drive-thumbnails"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
