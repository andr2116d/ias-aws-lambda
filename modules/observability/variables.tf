variable "name_prefix" {
  description = "Prefijo de nombres, por ejemplo image-processor-dev."
  type        = string
}

variable "dlq_name" {
  description = "Nombre de la dead-letter queue que monitorea la alarma."
  type        = string
}