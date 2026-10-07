output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.this[*].id
}

output "upload_lambda_sg_id" {
  value = aws_security_group.upload_lambda.id
}

output "crop_lambda_sg_id" {
  value = aws_security_group.crop_lambda.id
}

output "vpce_sqs_sg_id" {
  value = aws_security_group.vpce_sqs.id
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "sqs_endpoint_id" {
  value = aws_vpc_endpoint.sqs.id
}
