output "upload_role_arn" {
  description = "ARN del rol IAM para la Lambda de subida."
  value       = aws_iam_role.upload.arn
}

output "crop_role_arn" {
  description = "ARN del rol IAM para la Lambda de recorte."
  value       = aws_iam_role.crop.arn
}