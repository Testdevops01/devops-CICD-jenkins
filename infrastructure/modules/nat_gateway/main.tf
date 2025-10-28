resource "aws_eip" "nat_eip" {
tags = { Name = "tf-nat-eip" }
}


resource "aws_nat_gateway" "natgw" {
allocation_id = aws_eip.nat_eip.id
subnet_id = var.public_subnet
depends_on = []
tags = { Name = "tf-nat-gw" }
}

