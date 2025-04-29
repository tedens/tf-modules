variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS Key ID to use for server-side encryption"
  type        = string
  default     = ""
}

variable "acl" {
  description = "ACL policy for the bucket (e.g., private, public-read)"
  type        = string
  default     = "private"
}

variable "force_destroy" {
  description = "Force bucket deletion even if objects exist"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "Index document for website hosting"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Error document for website hosting"
  type        = string
  default     = "error.html"
}

variable "enable_redirect" {
  description = "Enable redirect-only bucket"
  type        = bool
  default     = false
}

variable "redirect_target_host" {
  description = "Redirect target hostname"
  type        = string
  default     = ""
}

variable "cors_rules" {
  description = "CORS rules for the bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "bucket_policy_json" {
  description = "Optional JSON for custom bucket policy"
  type        = string
  default     = ""
}

variable "logging_target_bucket" {
  description = "Bucket name where access logs should be stored"
  type        = string
  default     = ""
}

variable "logging_target_prefix" {
  description = "Prefix for logs stored in target bucket"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
