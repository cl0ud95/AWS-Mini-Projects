### Tested 16/1/2024, Working

# Provider clause
provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

### Generic VPC network setup

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = var.subnet_name
  }
}

# Create IGW
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = var.igw_name
  }
}

# Create route table with IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = var.igw_name
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create new security group open to HTTP traffic
resource "aws_security_group" "app_sg" {
  name = "app_SG_HTTP"
  vpc_id = aws_vpc.my_vpc.id
}

# Creates ingress and egress rules for SG
resource "aws_vpc_security_group_ingress_rule" "in_allow_all" {
  ip_protocol = "tcp"
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "out_allow_all" {
  ip_protocol = "-1"
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4 = "0.0.0.0/0"
}

### Testing with EC2 server
resource "aws_instance" "app_server" {
  ami = "ami-0c0b74d29acd0cd97" #Amazon Linux 2 AMI 64-bit x86
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex

  amazon-linux-extras install nginx1 -y
  echo "<h1>TYhis is my new server</h1>" >  /usr/share/nginx/html/index.html
  systemctl enable nginx
  systemctl start nginx
  EOF
  
  tags = {
    Name = "MyTestServer"
  }
}