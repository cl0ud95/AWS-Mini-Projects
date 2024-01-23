### To be deployed if var.CloudFront_deployment returns true
locals {
  s3_origin_id = "myS3Origin"
}

# Get existing zone in Route53, DO NOT CREATE NEW ONE TO PREVENT NS MISMATCH
data "aws_route53_zone" "my_dns" {
  name         = "headupintheclouds.net"
  private_zone = false
}

## Certification creation for custom domain in Route53
# Creates Certificate in ACM
resource "aws_acm_certificate" "domain_cert" {

  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
}

# Creates additional records in Route53 corresponding to the cert
resource "aws_route53_record" "cert_record" {

  for_each = {
    for dvo in aws_acm_certificate.domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
  zone_id         = data.aws_route53_zone.my_dns.id
}

# Validate cert
resource "aws_acm_certificate_validation" "domain_cert_valid" {

  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
}

## CloudFront Distribution Creation
# Manages an AWS CloudFront Origin Access Control, which is used by CloudFront Distributions with an Amazon S3 bucket as the origin.
resource "aws_cloudfront_origin_access_control" "s3_origin" {

  name                              = "s3_origin"
  description                       = "Policy for S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Creates Cloudfront Distribution
resource "aws_cloudfront_distribution" "dist" {

  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["${var.domain_name}", "www.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.domain_cert_valid.certificate_arn
    ssl_support_method       = "sni-only" #server name indication. Recommended solution
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

## Additional Bucket Permissions to allow OAC

data "aws_caller_identity" "me" {}

resource "aws_s3_bucket_policy" "s3_oac_access" {
  bucket = var.s3_bucket_id
  policy = <<-EOF
  {
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "${var.s3_bucket_arn}/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.me.account_id}:distribution/${aws_cloudfront_distribution.dist.id}"
                    }
                }
            }
        ]
  }
  EOF
}

## Create Alias record in Route53 to Cloudfront distribution
resource "aws_route53_record" "route_to_cf" {

  zone_id = data.aws_route53_zone.my_dns.id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id                = aws_cloudfront_distribution.dist.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_route_to_cf" {

  zone_id = data.aws_route53_zone.my_dns.id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id                = aws_cloudfront_distribution.dist.hosted_zone_id
    evaluate_target_health = true
  }
}