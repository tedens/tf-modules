# Terraform AWS S3 Bucket Module

## Overview

This Terraform module provisions an Amazon S3 bucket configured for multiple use cases:
- Flat storage (private buckets)
- CDN-optimized storage
- Static website hosting
- Redirect-only hosting
- Optional logging, encryption (AES256 or KMS), CORS, and access policies

Designed to be **enterprise-ready** with security best practices and full flexibility.

---

## Features

- Private or public S3 bucket creation
- Server-side encryption (default AES256 or optional KMS)
- Versioning support
- Static website hosting
- Redirect-only hosting
- Block public access settings (highly recommended by AWS)
- Bucket policy injection (custom JSON)
- Access logging to another S3 bucket
- CORS rule support
- Fine-grained ACL control
- Tags and lifecycle management

---

## Usage Examples

### 1. Flat Private Storage

```hcl
module "s3_storage" {
  source = "github.com/tedens/tf-modules//s3"

  bucket_name = "my-flat-storage-bucket"

  tags = {
    Project = "flat-storage"
    Owner   = "your-name"
  }
}
```

### 2. Optimized CDN

```hcl
module "s3_cdn" {
  source = "github.com/tedens/tf-modules//s3"

  bucket_name       = "cdn-optimized-bucket"
  enable_versioning = true
  enable_encryption = true
  acl               = "private"

  tags = {
    Project = "cdn"
    Owner   = "your-name"
  }
}
```

### 3. Static Website Hosting

```hcl
module "s3_website" {
  source = "github.com/tedens/tf-modules//s3"

  bucket_name           = "my-static-website-bucket"
  enable_static_website = true
  acl                   = "public-read"

  website_index_document = "index.html"
  website_error_document = "error.html"

  tags = {
    Project = "website"
  }
}
```

### 4. Redirect-Only Hosting

```hcl
module "s3_redirect" {
  source = "github.com/tedens/tf-modules//s3"

  bucket_name         = "redirect-bucket"
  enable_redirect     = true
  redirect_target_host = "www.example.com"

  tags = {
    Project = "redirect"
  }
}
```
### 5. Enable CORs rules

```hcl
module "s3_cors" {
  source = "github.com/tedens/tf-modules//s3"

  bucket_name = "cors-enabled-bucket"

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "POST"]
      allowed_origins = ["*"]
      expose_headers  = []
      max_age_seconds = 3000
    }
  ]

  tags = {
    Project = "cors"
  }
}
```

### 6. Bucket Logging and KMS Encryption
```hcl
module "s3_logging_kms" {
  source = "github.com/tedens/tf-modules//s3"

  bucket_name           = "secure-logging-bucket"
  enable_versioning     = true
  enable_encryption     = true
  kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/your-kms-key-id"
  
  logging_target_bucket = "s3-logs-bucket"
  logging_target_prefix = "secure-logs/"

  tags = {
    Project = "secure-logs"
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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | ACL policy for the bucket (e.g., private, public-read) | `string` | `"private"` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Block public ACLs | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Block public bucket policies | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_bucket_policy_json"></a> [bucket\_policy\_json](#input\_bucket\_policy\_json) | Optional JSON for custom bucket policy | `string` | `""` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS rules for the bucket | <pre>list(object({<br/>    allowed_headers = list(string)<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    expose_headers  = list(string)<br/>    max_age_seconds = number<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Enable server-side encryption | `bool` | `true` | no |
| <a name="input_enable_redirect"></a> [enable\_redirect](#input\_enable\_redirect) | Enable redirect-only bucket | `bool` | `false` | no |
| <a name="input_enable_static_website"></a> [enable\_static\_website](#input\_enable\_static\_website) | Enable static website hosting | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning on the bucket | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force bucket deletion even if objects exist | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Ignore public ACLs | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Optional KMS Key ID to use for server-side encryption | `string` | `""` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | Bucket name where access logs should be stored | `string` | `""` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | Prefix for logs stored in target bucket | `string` | `""` | no |
| <a name="input_redirect_target_host"></a> [redirect\_target\_host](#input\_redirect\_target\_host) | Redirect target hostname | `string` | `""` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Restrict public buckets | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the bucket | `map(string)` | `{}` | no |
| <a name="input_website_error_document"></a> [website\_error\_document](#input\_website\_error\_document) | Error document for website hosting | `string` | `"error.html"` | no |
| <a name="input_website_index_document"></a> [website\_index\_document](#input\_website\_index\_document) | Index document for website hosting | `string` | `"index.html"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Domain name of the bucket |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID (name) of the S3 bucket |
| <a name="output_website_endpoint"></a> [website\_endpoint](#output\_website\_endpoint) | Static website hosting endpoint (if enabled) |
<!-- END_TF_DOCS -->