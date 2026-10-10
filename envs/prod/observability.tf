module "observability" {
  source = "../../modules/observability"

  name_prefix = local.name_prefix
  dlq_name    = module.messaging.dlq_name
}