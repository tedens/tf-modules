variable "name" {
  description = "Name of the IAM role"
  type        = string
}

variable "description" {
  description = "Optional description for the IAM role"
  type        = string
  default     = ""
}

variable "path" {
  description = "Path for the role"
  type        = string
  default     = "/"
}

variable "assume_role_policy" {
  description = "JSON policy for who can assume the role"
  type        = string
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds)"
  type        = number
  default     = 3600
}

variable "permissions_boundary" {
  description = "ARN of the policy to use as permissions boundary"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of policy names to JSON policy bodies (as string)"
  type        = map(string)
  default     = {}
}

variable "force_detach_policies" {
  description = "Force detach all policies on destroy"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
