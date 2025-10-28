resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "public-rt"
  }
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "private-rt"
  }
}
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# Private route to NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gw_id
}
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = var.public_subnets[count.index]
  route_table_id = aws_route_table.public.id
}

# Private subnets
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = var.private_subnets[count.index]
  route_table_id = aws_route_table.private.id
}


