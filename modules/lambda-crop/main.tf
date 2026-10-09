data "archive_file" "crop" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/crop-lambda"
  output_path = "${path.module}/crop-lambda.zip"

  excludes = [
    "crop-lambda.zip",
    "package-lock.json"
  ]
}


resource "aws_lambda_function" "crop" {
  function_name    = "${var.name_prefix}-crop"
  role             = var.crop_role_arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  memory_size      = 512
  timeout          = 60
  filename         = data.archive_file.crop.output_path
  source_code_hash = data.archive_file.crop.output_base64sha256

  environment {
    variables = {
      S3_BUCKET        = var.bucket_name
      PROCESSED_PREFIX = "processed/"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.crop_lambda_sg_id]
  }

  logging_config {
    log_group  = var.crop_log_group_name
    log_format = "JSON"
  }
}