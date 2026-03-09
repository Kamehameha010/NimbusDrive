module "s3_events" {

  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 4.3.0"

  create_bus = false
  bus_name   = "default"

  rules = {
    s3_events = {
      name        = "s3-new-file-event-rule"
      description = "Rule to capture S3 events from NimbusDrive buckets"
      event_pattern = jsonencode({
        "source" : [
          "aws.s3"
        ],

        "region" : [var.aws_region]

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

  create_role = true
  role_name   = "Amazon_EventBridge_Invoke_Lambda-${random_string.iam_role_suffix[2].id}"

  lambda_target_arns   = [module.lambda_vectorize_function.lambda_function_arn]
  attach_lambda_policy = true


  targets = {
    s3_events = [
      {
        arn             = module.lambda_vectorize_function.lambda_function_arn
        name            = "lambda-vectorize"
        attach_role_arn = true
      }
    ]
  }

}
