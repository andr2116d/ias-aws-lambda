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

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.name_prefix}-dlq-messages-alarm"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    QueueName = var.dlq_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}