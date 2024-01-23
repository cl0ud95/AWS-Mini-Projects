variable "domain_name" {
  description = "DNS name of website"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 Bucket that is hosting the website"
  type        = string
}

variable "s3_bucket_arn" {
  description = "arn of S3 Bucket that is hosting the website"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "S3 Bucket regional domain name"
  type        = string
}