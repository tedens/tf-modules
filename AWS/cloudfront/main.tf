resource "aws_cloudfront_origin_access_control" "this" {
  for_each = {
    for origin in var.origins : origin.origin_id => origin
    if origin.origin_type == "s3" && origin.s3_origin_access.enable_oac
  }

  name                              = "${each.value.origin_id}-oac"
  description                       = "OAC for ${each.value.origin_id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  comment             = var.comment
  price_class         = var.price_class
  aliases             = var.aliases
  default_root_object = "index.html"

  dynamic "origin" {
    for_each = var.origins
    content {
      origin_id   = origin.value.origin_id
      domain_name = origin.value.domain_name
      origin_path = lookup(origin.value, "origin_path", null)

      dynamic "s3_origin_config" {
        for_each = origin.value.origin_type == "s3" && origin.value.s3_origin_access.enable_oac ? [1] : []
        content {
          origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_control.this[origin.key].name}"
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.origin_type == "custom" ? [1] : []
        content {
          http_port                = origin.value.custom_origin_config.http_port
          https_port               = origin.value.custom_origin_config.https_port
          origin_protocol_policy   = origin.value.custom_origin_config.origin_protocol_policy
          origin_ssl_protocols     = ["TLSv1.2"]
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = var.default_behavior.target_origin_id
    viewer_protocol_policy = var.default_behavior.viewer_protocol_policy
    allowed_methods        = var.default_behavior.allowed_methods
    cached_methods         = var.default_behavior.cached_methods
    compress               = var.default_behavior.compress
    cache_policy_id        = var.default_behavior.cache_policy_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version = var.acm_certificate_arn != "" ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket          = var.logging != null ? var.logging.bucket : null
    prefix          = var.logging != null && contains(keys(var.logging), "prefix") ? var.logging.prefix : null
    include_cookies = var.logging != null && contains(keys(var.logging), "include_cookies") ? var.logging.include_cookies : false
  }

  web_acl_id = var.web_acl_id != "" ? var.web_acl_id : null

  http_version   = var.http_version
  is_ipv6_enabled = var.ipv6_enabled

  tags = var.tags
}
