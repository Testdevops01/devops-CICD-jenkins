variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "igw_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "nat_gw_id" {
  description = "NAT Gateway ID" 
  type        = string
}
