variable "public_map_az_cidr" {
  description = "Map of names of AZs with the desired cidr for public subnets"
  type        = map(string)
}

variable "private_map_az_cidr" {
  description = "Map of names of AZs with the desired cidr for private subnets"
  type        = map(string)
}