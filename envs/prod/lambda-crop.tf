module "lambda_crop" {
  source = "../../modules/lambda-crop"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.network.private_subnet_ids
  crop_lambda_sg_id  = module.network.crop_lambda_sg_id
  crop_role_arn      = module.iam.crop_role_arn
  bucket_name        = module.storage.bucket_name
  queue_arn          = module.messaging.queue_arn

  crop_log_group_name = module.observability.crop_log_group_name
}
