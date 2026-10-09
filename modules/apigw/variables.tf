variable "name_prefix" {
  description = "Prefijo de nombres de los recursos (image-processor-<env>)."
  type        = string
}

variable "function_name" {
  description = "Nombre de la función Lambda de subida del módulo lambda-upload."
  type        = string
}

variable "invoke_arn" {
  description = "Invoke ARN de la función Lambda de subida del módulo lambda-upload."
  type        = string
}

variable "apigw_log_group_arn" {
  description = "ARN del log group de access logs del módulo observability."
  type        = string
}