variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS control plane and worker nodes"
  type        = list(string)
}

variable "enable_cluster_log_types" {
  description = "EKS control plane logs to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "cluster_iam_role_arn" {
  description = "Optional pre-created IAM role ARN for the EKS cluster"
  type        = string
  default     = ""
}

variable "node_role_arn" {
  description = "Optional pre-created IAM role ARN for the node group"
  type        = string
  default     = ""
}

variable "node_groups" {
  description = <<EOF
Map of managed node groups to create. Example:

node_groups = {
  default = {
    desired_size = 2
    max_size     = 4
    min_size     = 1
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
  }
}
EOF
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
  }))
  default = {}
}

variable "cluster_tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}

variable "node_group_tags" {
  description = "Tags to apply to all node groups"
  type        = map(string)
  default     = {}
}
