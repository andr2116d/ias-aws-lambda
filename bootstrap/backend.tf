terraform {
  backend "s3" {
    bucket       = "ias-aws-lambda-tfstate-741368364276"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
