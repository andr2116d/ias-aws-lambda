output "function_name" {
  description = "Nombre de la función Lambda de subida."
  value       = aws_lambda_function.upload.function_name
}

output "function_arn" {
  description = "ARN de la función Lambda de subida."
  value       = aws_lambda_function.upload.arn
}

output "invoke_arn" {
  description = "Invoke ARN de la función Lambda de subida, para API Gateway."
  value       = aws_lambda_function.upload.invoke_arn
}
