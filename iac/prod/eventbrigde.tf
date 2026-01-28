module "s3_events" {

  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 4.3.0"

  create_bus = false
  bus_name   = "default"


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
        ],
        "detail" : {
          "bucket" : {
            "name" : [{
              "equals-ignore-case" : module.s3_bucket_files.s3_bucket_id
            }]
          }
        }
      })

    }

  }


  targets = {
    s3_events_rule = [
      {
        arn = module.lambda_vectorize_function.lambda_function_arn
        name  = module.lambda_vectorize_function.lambda_function_name
      }
    ]
  }

  # depends_on = [
  #   module.s3_bucket_files,
  #   module.lambda_vectorize_function
  # ]
}
