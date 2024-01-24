### This resource file creates a VPC with 2 AZs and 2 subnets in each AZ, one public and one private
### A public and private route table will also be configured together with one NAT Gateway

# 1. Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-lab"
  }
}

# 2. Create IGW
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# 3. Create Subnets
resource "aws_subnet" "public_subnets" {
  for_each = var.private_map_az_cidr

  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Class = "VPC-lab-public"
    Name = "Public-Subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = var.public_map_az_cidr

  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Class = "VPC-lab-private"
    Name = "Private-Subnet-${each.key}"
  }
}

# 4. Create a NAT Gateway with Elastic IP for each private subnet
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.private_subnets
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = aws_subnet.private_subnets

  subnet_id         = each.value.id
  allocation_id     = aws_eip.nat_eip[each.key].id
  connectivity_type = "public"

  depends_on = [aws_eip.nat_eip]
  tags = {
    Name = "NAT-gw-${each.key}"
  }
}

# 5. Create 1 public rt and 1 private rt for each private subnet and associate igw or NAT gateways 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
}

resource "aws_route_table" "private_rt" {
  for_each = aws_nat_gateway.nat_gateway

  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
}

# 6. Associate route table with public subnets
resource "aws_route_table_association" "public_rt_assoc" {
  # 1 Route table for all public subnets
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  # 1 Route table for each private subnet
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}

# 7. Add VPC endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "endpoint_private_assoc" {
  for_each = aws_route_table.private_rt

  route_table_id = each.value.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}