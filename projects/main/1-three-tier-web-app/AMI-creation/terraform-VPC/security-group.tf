# Create new security group open to SSH and HTTP traffic
resource "aws_security_group" "ami_sg" {
  name = "web_server-sg"
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "http_allow_all" {
  ip_protocol = "tcp"
  security_group_id = aws_security_group.ami_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh_allow_all" {
  ip_protocol = "tcp"
  security_group_id = aws_security_group.ami_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
}

# Supposed to be default when creating in AWS console
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  ip_protocol = "-1"
  security_group_id = aws_security_group.ami_sg.id
  cidr_ipv4 = "0.0.0.0/0"
}