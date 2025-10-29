# EKS Cluster Role
resource "aws_iam_role" "eks_cluster" {
  name = "DevOpsTask6ClusterRole"  # Valid name without hyphens

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# EKS Node Group Role
resource "aws_iam_role" "eks_node" {
  name = "DevOpsTask6NodeRole"  # Valid name without hyphens

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
