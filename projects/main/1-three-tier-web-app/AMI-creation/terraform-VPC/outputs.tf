output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  description = "ID of public subnet in us-east-1"
  value = aws_subnet.public_subnets["us-east-1a"].id
}

output "sg_id" {
  value = aws_security_group.ami_sg.id
}