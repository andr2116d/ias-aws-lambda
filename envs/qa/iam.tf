module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  bucket_arn  = module.storage.bucket_arn
  queue_arn   = module.messaging.queue_arn
}