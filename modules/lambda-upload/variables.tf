variable "name_prefix" {
  description = "Prefijo de nombres de los recursos (image-processor-<env>)."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subredes privadas del módulo network donde corre la Lambda."
  type        = list(string)
}

variable "upload_lambda_sg_id" {
  description = "ID del security group sg-upload-lambda del módulo network."
  type        = string
}

variable "upload_role_arn" {
  description = "ARN del rol IAM de la Lambda de subida del módulo iam."
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket de imágenes del módulo storage."
  type        = string
}

variable "upload_log_group_name" {
  description = "Nombre del log group de la Lambda de subida del módulo observability."
  type        = string
}
