variable "vpc_id" {
type = string
}


variable "cidrs" {
type = list(string)
}


variable "az_count" {
type = number
default = 1
}

