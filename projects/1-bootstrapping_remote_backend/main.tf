terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.32.1"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "us-east-1"
}

### Bootstrapping Remote Backend for state file

resource "aws_s3_bucket" "terraform_state" {
  # Note that bucket names have to globally unique across all customers
  bucket = var.backend_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_s3_ent" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform_state_locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

### Bootstrapping end