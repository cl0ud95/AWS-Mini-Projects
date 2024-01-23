variable "backend_bucket_name" {
  description = "Name of S3 bucket to store tfstate file"
  type = string
  default = "devops-directive-tf-state-cl0ud95"
}

variable "backend_key" {
  description = "Name of VPC"
  type = string
  default = "tf-infra/terraform.tfstate"
}