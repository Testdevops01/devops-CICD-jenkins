########################################
# Global Settings
########################################
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

########################################
# Networking (VPC + Subnets)
########################################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

########################################
# Security Group Rules
########################################
variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_http_cidrs" {
  description = "CIDRs allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

########################################
# ECR Repository
########################################
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-app"
}

########################################
# EKS Cluster
########################################
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-devops-cluster"
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.micro"
}

variable "desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 3
}

########################################
# Tags (Optional, for tracking)
########################################
variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
  default     = "devops-pipeline-task6"
}

