output "api_endpoint" {
  description = "URL pública del API (usar con la ruta /upload)."
  value       = aws_apigatewayv2_api.this.api_endpoint
}