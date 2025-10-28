resource "aws_subnet" "public" {
for_each = { for idx, cidr in var.cidrs : idx => cidr }


vpc_id = var.vpc_id
cidr_block = each.value
map_public_ip_on_launch = true
availability_zone = element(data.aws_availability_zones.available.names, each.key)
tags = {
Name = "tf-public-${each.key}"
}
}


data "aws_availability_zones" "available" {}

