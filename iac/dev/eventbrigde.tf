module "s3_events" {

  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 4.3.0"

  bus_name = "nimbus-bus"


  rules = {
    s3_events_rule = {
      name        = "s3-new-file-event-rule"
      description = "Rule to capture S3 events from NimbusDrive buckets"
      event_pattern = jsonencode({
        "source" : [
          "aws.s3"
        ],

        "detail-type" : [
          "Object Created",
        ],

        "resources" : [
          module.s3_bucket_files.s3_bucket_arn
        ]
      })

    }

  }

  log_config = {
    include_detail = "FULL"
    level          = "INFO"

  }

  log_delivery = {
    s3 = {
      destination_arn = module.s3_bus_events.s3_bucket_arn
    }
  }

  lambda_target_arns = [
    module.lambda_vectorize_function.lambda_function_arn
  ]

  depends_on = [
    module.s3_bucket_files,
    module.lambda_vectorize_function
  ]
}
