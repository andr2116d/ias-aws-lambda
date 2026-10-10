output "queue_arn" {
  description = "ARN de la cola principal."
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "URL de la cola principal."
  value       = aws_sqs_queue.main.url
}

output "queue_name" {
  description = "Nombre de la cola principal."
  value       = aws_sqs_queue.main.name
}

output "dlq_arn" {
  description = "ARN de la dead-letter queue."
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "Nombre de la dead-letter queue."
  value       = aws_sqs_queue.dlq.name
}