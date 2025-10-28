########################################
# VPC Outputs
########################################
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.public_subnet.subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.private_subnet.subnet_ids
}

########################################
# ECR Outputs
########################################
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

########################################
# EKS Outputs
########################################
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Name of the node group"
  value       = module.eks.node_group_name
}

########################################
# General Outputs
########################################
output "project_name" {
  value = var.project_name
}

