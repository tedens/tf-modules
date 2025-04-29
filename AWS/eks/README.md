# Terraform AWS EKS Module

## Overview

This Terraform module provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster with fully managed node groups and optional custom IAM roles.  
It supports flexible input for scaling, tagging, and Kubernetes versioning.

Designed to be **enterprise-ready**, secure, and easy to integrate with existing VPCs and IAM infrastructure.

---

## Features

- Full EKS cluster provisioning
- Configurable managed node groups
- Optional custom IAM roles for control plane and nodes
- VPC/subnet input support
- Kubernetes version control
- Logging options for control plane
- Fully taggable cluster and node resources
- terraform-docs compatible

---

## Usage Examples

### 1. Basic EKS Cluster with One Node Group

```hcl
module "eks" {
  source = "github.com/tedens/tf-modules//eks"

  cluster_name        = "my-cluster"
  kubernetes_version  = "1.29"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private[*].id

  node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  cluster_tags = {
    Environment = "dev"
    Project     = "example"
  }

  node_group_tags = {
    Owner = "infra-team"
  }
}
```

---

### 2. EKS with Custom IAM Roles (Pre-Created)

```hcl
module "eks" {
  source = "github.com/tedens/tf-modules//eks"

  cluster_name       = "custom-iam-cluster"
  kubernetes_version = "1.28"
  vpc_id             = aws_vpc.shared.id
  subnet_ids         = aws_subnet.eks[*].id

  cluster_iam_role_arn = aws_iam_role.eks_control_plane.arn
  node_role_arn        = aws_iam_role.eks_node_group.arn

  node_groups = {
    workers = {
      desired_size   = 3
      max_size       = 5
      min_size       = 1
      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
    }
  }
}
```

---

### 3. EKS Cluster with Multiple Node Groups and Spot Instances

```hcl
module "eks" {
  source = "github.com/tedens/tf-modules//eks"

  cluster_name       = "multi-group-cluster"
  kubernetes_version = "1.29"
  vpc_id             = aws_vpc.eks.id
  subnet_ids         = aws_subnet.private[*].id

  node_groups = {
    on_demand = {
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
    },
    spot = {
      desired_size   = 2
      max_size       = 6
      min_size       = 1
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
    }
  }

  enable_cluster_log_types = ["api", "audit"]

  cluster_tags = {
    Project = "multi-env"
  }
}
```

---

## Terraform Inputs and Outputs

<!-- BEGIN_TF_DOCS:inputs -->
<!-- END_TF_DOCS:inputs -->

<!-- BEGIN_TF_DOCS:outputs -->
<!-- END_TF_DOCS:outputs -->

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
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_group_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_group_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.eks_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#input\_cluster\_iam\_role\_arn) | Optional pre-created IAM role ARN for the EKS cluster | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to apply to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_enable_cluster_log_types"></a> [enable\_cluster\_log\_types](#input\_enable\_cluster\_log\_types) | EKS control plane logs to enable | `list(string)` | <pre>[<br/>  "api",<br/>  "audit",<br/>  "authenticator"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the cluster | `string` | `"1.29"` | no |
| <a name="input_node_group_tags"></a> [node\_group\_tags](#input\_node\_group\_tags) | Tags to apply to all node groups | `map(string)` | `{}` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of managed node groups to create. Example:<br/><br/>node\_groups = {<br/>  default = {<br/>    desired\_size = 2<br/>    max\_size     = 4<br/>    min\_size     = 1<br/>    instance\_types = ["t3.medium"]<br/>    capacity\_type  = "ON\_DEMAND"<br/>  }<br/>} | <pre>map(object({<br/>    desired_size   = number<br/>    max_size       = number<br/>    min_size       = number<br/>    instance_types = list(string)<br/>    capacity_type  = string<br/>  }))</pre> | `{}` | no |
| <a name="input_node_role_arn"></a> [node\_role\_arn](#input\_node\_role\_arn) | Optional pre-created IAM role ARN for the node group | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS control plane and worker nodes | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the EKS cluster will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the EKS cluster |
| <a name="output_cluster_certificate_authority"></a> [cluster\_certificate\_authority](#output\_cluster\_certificate\_authority) | Base64 encoded certificate authority data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | API server endpoint of the EKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | Kubernetes version of the EKS cluster |
<!-- END_TF_DOCS -->