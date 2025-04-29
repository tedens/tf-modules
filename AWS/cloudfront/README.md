# Terraform AWS CloudFront Module

## Overview

This Terraform module provisions a highly configurable AWS CloudFront distribution.  
It supports S3 origins, ALB/API/custom origins, custom SSL certificates, logging, WAF integration, HTTP/3, and more.

Designed to be **enterprise-ready** with flexibility for any project.

---

## Features

- S3, ALB, API Gateway, EC2 origins
- Origin Access Control (OAC) support for private S3 buckets
- Default SSL certificate or ACM custom SSL cert
- Optional WAF Web ACL integration
- Custom cache policies
- Price class control (global or regional)
- Access logs to S3
- IPv6 and HTTP/3 support
- Terraform-docs ready documentation

---

## Usage Examples

### STEP 1. Basic CloudFront with S3 Public Origin

```hcl
module "cloudfront_basic_s3" {
  source = "github.com/tedens/tf-modules//cloudfront"

  comment = "Basic CloudFront with S3 Origin"

  origins = [
    {
      origin_id   = "s3-origin"
      domain_name = "mybucket.s3.amazonaws.com"
      origin_type = "s3"
      s3_origin_access = {
        enable_oac = false
      }
    }
  ]

  default_behavior = {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed CachingOptimized
    compress               = true
  }

  tags = {
    Project = "basic-cloudfront"
  }
}
```

### 2. CloudFront with Private S3 Bucket (OAC)

```hcl
module "cloudfront_private_s3" {
  source = "github.com/tedens/tf-modules//cloudfront"

  comment = "CloudFront with OAC Private S3 Origin"

  origins = [
    {
      origin_id   = "private-s3-origin"
      domain_name = "myprivatebucket.s3.amazonaws.com"
      origin_type = "s3"
      s3_origin_access = {
        enable_oac = true
      }
    }
  ]

  default_behavior = {
    target_origin_id       = "private-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  acm_certificate_arn = aws_acm_certificate.main.arn

  tags = {
    Project = "private-s3-cloudfront"
  }
}
```

### 3. CloudFront Fronting an Application Load Balancer (ALB)

```hcl
module "cloudfront_alb" {
  source = "github.com/tedens/tf-modules//cloudfront"

  comment = "CloudFront Fronting ALB"

  origins = [
    {
      origin_id   = "alb-origin"
      domain_name = aws_lb.myapp.dns_name
      origin_type = "custom"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
      }
    }
  ]

  default_behavior = {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "08627262-05a9-4f76-9ded-b50ca2e3a84f" # Managed CachingDisabled
    compress               = true
  }

  acm_certificate_arn = aws_acm_certificate.alb_cert.arn

  tags = {
    Project = "alb-cloudfront"
  }
}
```

### 4. CloudFront with Logging and WAF Protection

```hcl
module "cloudfront_logging_waf" {
  source = "github.com/tedens/tf-modules//cloudfront"

  comment = "CloudFront with Logging and WAF"

  origins = [
    {
      origin_id   = "s3-origin-with-logs"
      domain_name = "mys3bucket.s3.amazonaws.com"
      origin_type = "s3"
      s3_origin_access = {
        enable_oac = false
      }
    }
  ]

  default_behavior = {
    target_origin_id       = "s3-origin-with-logs"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  web_acl_id = aws_wafv2_web_acl.cloudfront_acl.arn

  logging = {
    bucket          = "logs-bucket.s3.amazonaws.com"
    prefix          = "cloudfront/"
    include_cookies = false
  }

  tags = {
    Project = "cloudfront-waf-logs"
  }
}
```

<!-- BEGIN_TF_DOCS:inputs --> <!-- END_TF_DOCS:inputs -->
<!-- BEGIN_TF_DOCS:outputs --> <!-- END_TF_DOCS:outputs -->
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the ACM SSL certificate | `string` | `""` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Alternate domain names (CNAMEs) | `list(string)` | `[]` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Optional comment for the distribution | `string` | `""` | no |
| <a name="input_default_behavior"></a> [default\_behavior](#input\_default\_behavior) | Default cache behavior | <pre>object({<br/>    viewer_protocol_policy = string<br/>    allowed_methods        = list(string)<br/>    cached_methods         = list(string)<br/>    target_origin_id       = string<br/>    cache_policy_id        = string<br/>    compress               = bool<br/>  })</pre> | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled | `bool` | `true` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | HTTP version to support (e.g., http2, http3) | `string` | `"http3"` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | Enable IPv6 | `bool` | `true` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Logging configuration | <pre>object({<br/>    bucket          = string<br/>    prefix          = optional(string)<br/>    include_cookies = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | List of origin definitions | <pre>list(object({<br/>    origin_id   = string<br/>    domain_name = string<br/>    origin_type = string # "s3" or "custom"<br/>    origin_path = optional(string)<br/>    custom_origin_config = optional(object({<br/>      http_port              = number<br/>      https_port             = number<br/>      origin_protocol_policy = string<br/>    }))<br/>    s3_origin_access = optional(object({<br/>      enable_oac = bool<br/>      oac_policy = optional(string)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | Price class for distribution | `string` | `"PriceClass_All"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the CloudFront distribution | `map(string)` | `{}` | no |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | WAF Web ACL ID to associate | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | ARN of the CloudFront distribution |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | Domain name of the CloudFront distribution |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | ID of the CloudFront distribution |
| <a name="output_distribution_status"></a> [distribution\_status](#output\_distribution\_status) | Current status of the CloudFront distribution |
<!-- END_TF_DOCS -->