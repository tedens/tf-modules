variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda runtime (e.g., nodejs18.x, python3.11)"
  type        = string
}

variable "handler" {
  description = "Lambda function handler (e.g., index.handler)"
  type        = string
}

variable "source_path" {
  description = "Path to local ZIP file or directory"
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = "S3 bucket for Lambda deployment package (optional)"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 key for Lambda deployment package (optional)"
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Amount of memory in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout in seconds"
  type        = number
  default     = 3
}

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

variable "role_arn" {
  description = "IAM Role ARN to attach to the Lambda (optional, otherwise auto-created)"
  type        = string
  default     = ""
}

variable "create_role" {
  description = "Create a basic execution IAM Role"
  type        = bool
  default     = true
}

variable "layers" {
  description = "List of Lambda layer ARNs"
  type        = list(string)
  default     = []
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs for VPC access"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for VPC access"
  type        = list(string)
  default     = []
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrency limit"
  type        = number
  default     = -1
}

variable "dead_letter_target_arn" {
  description = "ARN of SQS queue or SNS topic for failed executions"
  type        = string
  default     = ""
}

variable "log_retention_in_days" {
  description = "Retention period for CloudWatch logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "image_uri" {
  description = "ECR Image URI for the Lambda function (for container-based deployment)"
  type        = string
  default     = ""
}

variable "package_type" {
  description = "Package type for the Lambda function (Zip or Image)"
  type        = string
  default     = "Zip"
}