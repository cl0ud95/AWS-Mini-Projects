<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.32.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.32.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront_config"></a> [cloudfront\_config](#module\_cloudfront\_config) | ./modules/CloudFront | n/a |
| <a name="module_route53_config"></a> [route53\_config](#module\_route53\_config) | ./modules/Route53 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.s3_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_versioning.s3_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.website_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CloudFront_deployment"></a> [CloudFront\_deployment](#input\_CloudFront\_deployment) | If true, website will be deployed with CloudFront(takes more time to validate certifications), if not, route53 is used | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | DNS name of website | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->