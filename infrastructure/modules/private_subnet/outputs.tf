output "subnet_ids" {
value = [for s in aws_subnet.private : s.id]
}

