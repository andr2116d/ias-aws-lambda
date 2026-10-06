variable "name_prefix" {
  description = "Prefijo de nombres, por ejemplo image-processor-dev."
  type        = string
}

variable "aws_region" {
  description = "Región de AWS."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZ-a y AZ-b."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Subredes públicas en AZ-a y AZ-b."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Subredes privadas en AZ-a y AZ-b."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "images_bucket_arn" {
  description = "ARN del bucket de imágenes para la política del S3 Gateway Endpoint."
  type        = string
}
