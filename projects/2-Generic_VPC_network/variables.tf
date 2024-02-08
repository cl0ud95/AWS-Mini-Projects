variable "vpc_name" {
  description = "Name of VPC"
  type = string
  default = "MyTestVPC"
}

variable "vpc_cidr" {
  description = "Name of VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Name of subnet"
  type = string
  default = "MyTestSubnet"
}

variable "subnet_cidr" {
  description = "Name of VPC"
  type = string
  default = "10.0.1.0/24"
}

variable "igw_name" {
  description = "Name of Internet Gateway"
  type = string
  default = "MyTestIGW"
}
