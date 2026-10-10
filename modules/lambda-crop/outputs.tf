output "function_name" {
  description = "Nombre de la función Lambda de recorte."
  value       = aws_lambda_function.crop.function_name
}

output "function_arn" {
  description = "ARN de la función Lambda de recorte."
  value       = aws_lambda_function.crop.arn
}