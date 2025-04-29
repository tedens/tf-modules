output "bucket_id" {
  description = "ID (name) of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "website_endpoint" {
  description = "Static website hosting endpoint (if enabled)"
  value       = var.enable_static_website || var.enable_redirect ? aws_s3_bucket.this.website_endpoint : null
}
