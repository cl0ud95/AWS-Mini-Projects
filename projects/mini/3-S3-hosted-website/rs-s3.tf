### S3 bucket setup
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "www.${var.domain_name}" #has to match subdomain exactly
}

locals {
  bucketid = aws_s3_bucket.s3_bucket.id
}

# Versioning
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = local.bucketid
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload website resource files
resource "aws_s3_object" "website_files" {
  bucket = local.bucketid

  for_each     = fileset("html/", "**/*.*")
  key          = each.value
  source       = "html/${each.value}"
  content_type = each.value
}

# CORS policy
resource "aws_s3_bucket_cors_configuration" "s3_cors" {
  bucket = local.bucketid
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = [var.domain_name]
    max_age_seconds = 3000
  }
}