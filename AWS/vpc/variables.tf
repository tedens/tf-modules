variable "name" {
  description = "Name prefix for the VPC and related resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Whether to create a single shared NAT Gateway (true) or one per AZ (false)"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of Availability Zones to distribute subnets into"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}
