module "s3_bucket_files" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "nimbus-drive"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}


module "s3_bucket_thumbnails" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "nimbus-thumbnails-drive"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}


module "s3_bus_events" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "bus-event-logs-nimbus-${random_string.suffix[2].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

}


module "s3_nimbus_share_layer" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "nimbus-layers-${random.suffix[3].id}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

