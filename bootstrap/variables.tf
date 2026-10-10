variable "aws_region" {
  description = "Región de AWS donde se despliega toda la arquitectura."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nombre del proyecto, usado para nombrar los recursos."
  type        = string
  default     = "ias-aws-lambda"
}

variable "resource_prefix" {
  description = "Prefijo de los recursos de la arquitectura, nos guiamos del diagrama (image-processor-<env>-...)."
  type        = string
  default     = "image-processor"
}

variable "github_owner" {
  description = "Dueño del repo."
  type        = string
  default     = "andr2116d"
}

variable "github_repo" {
  description = "Nombre del repositorio en GitHub."
  type        = string
  default     = "ias-aws-lambda"
}

variable "environments" {
  description = "Entornos de despliegue. Cada uno tendrá su propio rol de deploy y su environment en GitHub."
  type        = list(string)
  default     = ["dev", "qa", "prod"]
}

variable "budget_alert_email" {
  description = "Correo que recibe las alertas de gasto. Se define en bootstrap.local.tfvars, que no se sube al repositorio."
  type        = string
}

variable "monthly_budget_usd" {
  description = "Límite mensual de gasto en USD para toda la cuenta."
  type        = string
  default     = "5"
}

variable "github_owner_id" {
  description = "ID numérico del dueño del repositorio en GitHub."
  type        = string
  default     = "168318341"
}

variable "github_repo_id" {
  description = "ID numérico del repositorio en GitHub."
  type        = string
  default     = "1407843817"
}
