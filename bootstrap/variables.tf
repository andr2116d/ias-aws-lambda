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
