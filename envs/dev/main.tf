locals {
  name_prefix = "image-processor-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  name_prefix       = local.name_prefix
  aws_region        = var.aws_region
  images_bucket_arn = "arn:aws:s3:::${local.name_prefix}-images-*"
}
