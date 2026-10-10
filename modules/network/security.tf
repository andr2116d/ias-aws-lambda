resource "aws_security_group" "upload_lambda" {
  name        = "${var.name_prefix}-upload-lambda"
  description = "sg-upload-lambda"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "sg-upload-lambda"
  }
}

resource "aws_security_group" "crop_lambda" {
  name        = "${var.name_prefix}-crop-lambda"
  description = "sg-crop-lambda"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "sg-crop-lambda"
  }
}

resource "aws_security_group" "vpce_sqs" {
  name        = "${var.name_prefix}-vpce-sqs"
  description = "sg-vpce-sqs"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "sg-vpce-sqs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpce_sqs_from_upload" {
  security_group_id            = aws_security_group.vpce_sqs.id
  referenced_security_group_id = aws_security_group.upload_lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "vpce_sqs_from_crop" {
  security_group_id            = aws_security_group.vpce_sqs.id
  referenced_security_group_id = aws_security_group.crop_lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "upload_to_s3" {
  security_group_id = aws_security_group.upload_lambda.id
  prefix_list_id    = aws_vpc_endpoint.s3.prefix_list_id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "upload_to_sqs" {
  security_group_id            = aws_security_group.upload_lambda.id
  referenced_security_group_id = aws_security_group.vpce_sqs.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "crop_to_s3" {
  security_group_id = aws_security_group.crop_lambda.id
  prefix_list_id    = aws_vpc_endpoint.s3.prefix_list_id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "crop_to_sqs" {
  security_group_id            = aws_security_group.crop_lambda.id
  referenced_security_group_id = aws_security_group.vpce_sqs.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}
