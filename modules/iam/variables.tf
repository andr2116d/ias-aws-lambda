variable "name_prefix" {
  description = "Prefijo de nombres de los recursos IAM."
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket de S3 del módulo storage."
  type        = string
}

variable "queue_arn" {
  description = "ARN de la cola principal del módulo messaging."
  type        = string
}