module "storage" {
  source = "../../modules/storage"

  name_prefix   = local.name_prefix
  queue_arn     = module.messaging.queue_arn
  queue_url     = module.messaging.queue_url
  force_destroy = true
}