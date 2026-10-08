output "upload_log_group_name" {
  description = "Nombre del log group de la lambda upload."
  value       = aws_cloudwatch_log_group.upload.name
}

output "crop_log_group_name" {
  description = "Nombre del log group de la lambda crop."
  value       = aws_cloudwatch_log_group.crop.name
}

output "apigw_log_group_arn" {
  description = "ARN del log group del access log de API Gateway."
  value       = aws_cloudwatch_log_group.apigw.arn
}

output "sns_topic_arn" {
  description = "ARN del topic SNS de alertas."
  value       = aws_sns_topic.alerts.arn
}