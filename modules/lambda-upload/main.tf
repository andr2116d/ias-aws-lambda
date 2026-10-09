data "archive_file" "upload" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/upload-lambda"
  output_path = "${path.module}/upload-lambda.zip"
}

resource "aws_lambda_function" "upload" {
  function_name    = "${var.name_prefix}-upload"
  role             = var.upload_role_arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  memory_size      = 256
  timeout          = 30
  filename         = data.archive_file.upload.output_path
  source_code_hash = data.archive_file.upload.output_base64sha256

  environment {
    variables = {
      S3_BUCKET     = var.bucket_name
      UPLOAD_PREFIX = "uploads/"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.upload_lambda_sg_id]
  }

  logging_config {
    log_group  = var.upload_log_group_name
    log_format = "JSON"
  }
}