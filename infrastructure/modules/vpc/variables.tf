variable "vpc_cidr" {
type = string
}
variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

