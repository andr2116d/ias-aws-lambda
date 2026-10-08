variable "name_prefix" {
  description = "Prefijo de nombres, por ejemplo image-processor-dev."
  type        = string
}

variable "queue_arn" {
  description = "ARN de la cola principal de messaging."
  type        = string
}

variable "queue_url" {
  description = "URL de la cola principal de messaging."
  type        = string
}

variable "force_destroy" {
  description = "Permite eliminar el bucket aunque contenga objetos."
  type        = bool
  default     = false
}