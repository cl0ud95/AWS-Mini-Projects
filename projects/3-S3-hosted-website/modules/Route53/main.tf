# Get existing zone in Route53, DO NOT CREATE NEW ONE TO PREVENT NS MISMATCH
data "aws_route53_zone" "my_dns" {
  name         = "headupintheclouds.net"
  private_zone = false
}

resource "aws_route53_record" "route_to_bucket" {

  zone_id = data.aws_route53_zone.my_dns.id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = "s3-website-us-east-1.amazonaws.com"
    zone_id                = "Z3AQBSTGFYJSTF" # us-east-1 hosted zone ID for Route53
    evaluate_target_health = true
  }
}

# to access www website
resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.my_dns.id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "s3-website-us-east-1.amazonaws.com"
    zone_id                = "Z3AQBSTGFYJSTF" # us-east-1 hosted zone ID for Route53
    evaluate_target_health = true
  }
}

### Additional modifications for S3 bucket
resource "aws_s3_bucket_public_access_block" "s3_pub_acc" {

  bucket                  = var.s3_bucket_id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_owner" {
  bucket = var.s3_bucket_id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = var.s3_bucket_id
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_owner,
    aws_s3_bucket_public_access_block.s3_pub_acc,
  ]

  acl = "public-read"
}

# Website config for bucket
resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = var.s3_bucket_id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#IAM Access Policy
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_iam_policy.json
}

data "aws_iam_policy_document" "s3_iam_policy" {
  statement {
    sid    = "PublicReadForGetBucketObjects"
    effect = "Allow"

    resources = [
      "${var.s3_bucket_arn}/*"
    ]

    actions = ["S3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}