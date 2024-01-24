packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.9"
    }
  }
}

source "amazon-ebs" "amazon_linux_2023" {
  ami_name = "base-ami"
  instance_type = "t2.micro"
  region = "us-east-1"
  source_ami = "ami-0a3c3a20c09d6f377" 
  ssh_username = "ec2-user"
  associate_public_ip_address = true
  vpc_id = var.vpc_id
  subnet_id = var.subnet_id
  security_group_id = var.sg_id

  ## Using security_group_filter will return the following error: InvalidParameterValue: Value () for parameter groupId is invalid. The value cannot be empty
  // security_group_filter {
  //   filters = {
  //     "tag:Name": "web-server-testing" # Ref to terrafrom
  //   }
  // }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }
  imds_support  = "v2.0" # enforces imdsv2 support on the resulting AMI
}

build {
  name = "web-server-ami"
  sources = ["source.amazon-ebs.amazon_linux_2023"]

  provisioner "shell" {
    inline = [
      "echo 'Sleeping for 30 seconds for OS to initialize.'",
      "sleep 30",
    ]
  }

  ## Running script with sudo privileges
  provisioner "shell" {
    execute_command = "echo 'ec2-user' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    script = "${path.root}/user-data.sh"
  }

  ## Alternative approach
  // provisioner "file" {
  //   source = "${path.root}/user-data.sh"
  //   destination = "~/shell.tmp.sh"
  // }

  // provisioner "shell" {
  //   inline = ["sudo bash ~/shell.tmp.sh", "rm ~/shell.tmp.sh"]
  // }
}