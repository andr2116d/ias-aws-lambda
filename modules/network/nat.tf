resource "aws_eip" "nat" {
  count = length(aws_subnet.public)

  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip-${substr(var.availability_zones[count.index], -1, 1)}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = length(aws_subnet.public)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name_prefix}-nat-${substr(var.availability_zones[count.index], -1, 1)}"
  }

  depends_on = [aws_internet_gateway.this]
}
