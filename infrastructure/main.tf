###################################
# VPC and Networking
###################################
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
}

module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
}

module "public_subnet" {
  source   = "./modules/public_subnet"
  vpc_id   = module.vpc.vpc_id
  az_count = var.az_count
  cidrs    = var.public_subnet_cidrs
}

module "private_subnet" {
  source   = "./modules/private_subnet"
  vpc_id   = module.vpc.vpc_id
  az_count = var.az_count
  cidrs    = var.private_subnet_cidrs
}

module "nat_gateway" {
  source        = "./modules/nat_gateway"
  vpc_id        = module.vpc.vpc_id
  public_subnet = element(module.public_subnet.subnet_ids, 0)
}

module "route_tables" {
  source          = "./modules/route_tables"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.public_subnet.subnet_ids
  private_subnets = module.private_subnet.subnet_ids
  igw_id          = module.internet_gateway.igw_id
  nat_gw_id       = module.nat_gateway.nat_gateway_id
}

###################################
# Security Groups
###################################
module "security_group" {
  source         = "./modules/security_group"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.public_subnet.subnet_ids
}

###################################
# IAM Roles (for EKS & Node Groups)
###################################
module "iam" {
  source = "./modules/iam"
}

###################################
# ECR Repository
###################################
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}

###################################
# EKS Cluster
###################################
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.public_subnet.subnet_ids
  private_subnets    = module.private_subnet.subnet_ids
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  cluster_name       = var.cluster_name
  desired_size       = var.desired_size
  max_size           = var.max_size
  min_size           = var.min_size
  instance_type      = var.node_instance_type
}
