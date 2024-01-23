variable "CloudFront_deployment" {
  description = "If true, website will be deployed with CloudFront(takes more time to validate certifications), if not, route53 is used"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "DNS name of website"
  type        = string
}