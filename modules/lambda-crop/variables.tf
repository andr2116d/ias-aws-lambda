variable "name_prefix" {
  description = "Prefijo para nombrar los recursos de la función Lambda."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subredes privadas para la función Lambda."
  type        = list(string)
}

variable "crop_lambda_sg_id" {
  description = "ID del grupo de seguridad de la función de recorte."
  type        = string
}

variable "crop_role_arn" {
  description = "ARN del rol IAM de la función de recorte."
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket S3."
  type        = string
}

variable "queue_arn" {
  description = "ARN de la cola principal SQS."
  type        = string
}

variable "crop_log_group_name" {
  description = "Nombre del grupo de logs de la función."
  type        = string
}