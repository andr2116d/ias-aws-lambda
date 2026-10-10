module "apigw" {
  source = "../../modules/apigw"

  name_prefix         = local.name_prefix
  function_name       = module.lambda_upload.function_name
  invoke_arn          = module.lambda_upload.invoke_arn
  apigw_log_group_arn = module.observability.apigw_log_group_arn
}