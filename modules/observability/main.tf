resource "aws_cloudwatch_log_group" "upload" {
  name              = "/aws/lambda/${var.name_prefix}-upload"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "crop" {
  name              = "/aws/lambda/${var.name_prefix}-crop"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "apigw" {
  name              = "/aws/apigateway/${var.name_prefix}"
  retention_in_days = 14
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"
}