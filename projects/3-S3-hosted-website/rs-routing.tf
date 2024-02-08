module "route53_config" {
  count  = var.CloudFront_deployment ? 0 : 1
  source = "./modules/Route53"

  domain_name           = var.domain_name
  s3_bucket_id          = aws_s3_bucket.s3_bucket.id
  s3_bucket_domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  s3_bucket_arn         = aws_s3_bucket.s3_bucket.arn
}

module "cloudfront_config" {
  count  = var.CloudFront_deployment ? 1 : 0
  source = "./modules/CloudFront"

  domain_name           = var.domain_name
  s3_bucket_id          = aws_s3_bucket.s3_bucket.id
  s3_bucket_domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  s3_bucket_arn         = aws_s3_bucket.s3_bucket.arn
}