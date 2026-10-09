module "lambda_upload" {
  source = "../../modules/lambda-upload"

  name_prefix           = local.name_prefix
  private_subnet_ids    = module.network.private_subnet_ids
  upload_lambda_sg_id   = module.network.upload_lambda_sg_id
  upload_role_arn       = module.iam.upload_role_arn
  bucket_name           = module.storage.bucket_name
  upload_log_group_name = module.observability.upload_log_group_name
}