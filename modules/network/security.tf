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
