variable "comment" {
  description = "Optional comment for the distribution"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "origins" {
  description = "List of origin definitions"
  type = list(object({
    origin_id   = string
    domain_name = string
    origin_type = string # "s3" or "custom"
    origin_path = optional(string)
    custom_origin_config = optional(object({
      http_port              = number
      https_port             = number
      origin_protocol_policy = string
    }))
    s3_origin_access = optional(object({
      enable_oac = bool
      oac_policy = optional(string)
    }))
  }))
}

variable "default_behavior" {
  description = "Default cache behavior"
  type = object({
    viewer_protocol_policy = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    target_origin_id       = string
    cache_policy_id        = string
    compress               = bool
  })
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM SSL certificate"
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs)"
  type        = list(string)
  default     = []
}

variable "price_class" {
  description = "Price class for distribution"
  type        = string
  default     = "PriceClass_All"
}

variable "logging" {
  description = "Logging configuration"
  type = object({
    bucket          = string
    prefix          = optional(string)
    include_cookies = optional(bool)
  })
  default = null
}

variable "web_acl_id" {
  description = "WAF Web ACL ID to associate"
  type        = string
  default     = ""
}

variable "http_version" {
  description = "HTTP version to support (e.g., http2, http3)"
  type        = string
  default     = "http3"
}

variable "ipv6_enabled" {
  description = "Enable IPv6"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the CloudFront distribution"
  type        = map(string)
  default     = {}
}
