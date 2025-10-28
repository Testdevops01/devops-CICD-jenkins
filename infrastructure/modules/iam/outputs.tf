output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node role"
  value       = aws_iam_role.eks_node.arn
}
