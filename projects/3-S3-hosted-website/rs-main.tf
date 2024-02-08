terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32.1"
    }
  }

  # terraform init -backend-config="../../env/backend-mini-projects.hcl"
  backend "s3" {}
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
