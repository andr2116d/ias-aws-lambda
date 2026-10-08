data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "images" {
  bucket        = "${var.name_prefix}-images-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.name_prefix}-images"
  }
}