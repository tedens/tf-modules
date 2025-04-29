variable "name" {
  description = "Name prefix for the EC2 instances"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 1
}

variable "use_launch_template" {
  description = "Use a launch template instead of direct aws_instance"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use, unless dynamic AMI is enabled"
  type        = string
  default     = ""
}

variable "use_dynamic_ami" {
  description = "Enable dynamic AMI lookup using filters"
  type        = bool
  default     = false
}

variable "ami_name_filter" {
  description = "Filter string for dynamic AMI lookup"
  type        = string
  default     = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "ami_owners" {
  description = "Owners list for dynamic AMI lookup"
  type        = list(string)
  default     = ["amazon"]
}

variable "subnet_id" {
  description = "Subnet ID to launch instance into"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP"
  type        = bool
  default     = true
}

variable "allocate_eip" {
  description = "Allocate Elastic IP(s) and associate"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of SGs to attach"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Inline user data script"
  type        = string
  default     = ""
}

variable "user_data_file" {
  description = "Path to file with user data (overrides inline)"
  type        = string
  default     = ""
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "enable_hibernation" {
  description = "Enable instance hibernation"
  type        = bool
  default     = false
}

variable "metadata_http_tokens" {
  description = "IMDSv2 http_tokens setting (optional)"
  type        = string
  default     = "required"
}

variable "metadata_http_endpoint" {
  description = "IMDS endpoint setting"
  type        = string
  default     = "enabled"
}

variable "prevent_destroy" {
  description = "Prevent instance destruction"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  type        = number
  default     = 8
}

variable "root_volume_type" {
  type        = string
  default     = "gp3"
}

variable "root_volume_iops" {
  type        = number
  default     = null
}

variable "ebs_volumes" {
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
  }))
  default = []
}

variable "instance_tags" {
  description = "List of tag maps per instance index"
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "Base tags for all resources"
  type        = map(string)
  default     = {}
}
