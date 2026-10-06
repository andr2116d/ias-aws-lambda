output "aws_region" {
  description = "Región de despliegue."
  value       = var.aws_region
}

output "state_bucket_name" {
  description = "Bucket del estado remoto. Se usa en envs/<env>/backend.tf."
  value       = aws_s3_bucket.tfstate.bucket
}

output "oidc_provider_arn" {
  description = "Proveedor OIDC de GitHub Actions."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "deploy_role_arns" {
  description = "Rol de despliegue por entorno. Se configura como variable AWS_ROLE_ARN en cada environment de GitHub."
  value       = { for env, role in aws_iam_role.deploy : env => role.arn }
}

output "plan_role_arn" {
  description = "Rol de solo lectura para terraform plan en pull requests."
  value       = aws_iam_role.plan.arn
}
