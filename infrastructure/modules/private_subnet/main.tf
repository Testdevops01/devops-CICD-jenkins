resource "aws_subnet" "private" {
for_each = { for idx, cidr in var.cidrs : idx => cidr }


vpc_id = var.vpc_id
cidr_block = each.value
map_public_ip_on_launch = false
availability_zone = element(data.aws_availability_zones.available.names, each.key)
tags = {
Name = "tf-private-${each.key}"
}
}


data "aws_availability_zones" "available" {}

