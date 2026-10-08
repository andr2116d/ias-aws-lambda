resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-image-dlq"
  message_retention_seconds = 1209600
}
