# Terraform AWS IAM Role Module

## Overview

This Terraform module provisions a flexible, enterprise-grade IAM role with support for:

- Trust policies for EC2, Lambda, OIDC, and cross-account use cases
- Inline policies and managed policy attachments
- Permissions boundary support
- Custom path, max session duration, and tags

Designed to be **secure, scalable, and compatible** with any AWS IAM use case.

---

## Features

- IAM role creation with custom name and path
- Custom trust policy (assume role)
- Attach multiple managed policies
- Add inline policies as string or from files
- Permissions boundary support
- Force-detach policy control on destroy
- Max session duration override
- Full tagging support

---

## Usage Examples

### 1. Basic Lambda Execution Role

```hcl
module "lambda_role" {
  source = "github.com/tedens/tf-modules//iam"

  name               = "lambda-basic-role"
  description        = "IAM role for Lambda function"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = {
    Project = "lambda"
    Env     = "dev"
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
```

### 2. EC2 Role with Inline Policy

```hcl
module "ec2_role" {
  source = "github.com/tedens/tf-modules//iam"

  name               = "ec2-access-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  inline_policies = {
    "ec2-s3-access" = data.aws_iam_policy_document.ec2_s3_policy.json
  }

  tags = {
    Role = "ec2"
  }
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::my-secure-bucket/*"]
  }
}
```

### 3. Cross-Account Assume Role

```hcl
module "cross_account_role" {
  source = "github.com/tedens/tf-modules//iam"

  name               = "cross-account-access"
  assume_role_policy = data.aws_iam_policy_document.cross.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Purpose = "cross-account"
  }
}

data "aws_iam_policy_document" "cross" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:root"]
    }
  }
}
```

### 4. GitHub OIDC Role for CI/CD

```hcl
module "github_oidc_role" {
  source = "github.com/tedens/tf-modules//iam"

  name               = "github-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  tags = {
    Owner = "devops"
  }
}

data "aws_iam_policy_document" "github_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:myorg/myrepo:*"]
    }
  }
}
```

### 5. IAM Role with Permissions Boundary

```hcl
module "bounded_role" {
  source = "github.com/tedens/tf-modules//iam"

  name               = "restricted-role"
  assume_role_policy = data.aws_iam_policy_document.boundary_test.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  permissions_boundary = "arn:aws:iam::123456789012:policy/org-boundary-policy"

  tags = {
    Env = "prod"
  }
}

data "aws_iam_policy_document" "boundary_test" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
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
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | JSON policy for who can assume the role | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Optional description for the IAM role | `string` | `""` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Force detach all policies on destroy | `bool` | `true` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | Map of policy names to JSON policy bodies (as string) | `map(string)` | `{}` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of managed policy ARNs to attach | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration (in seconds) | `number` | `3600` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM role | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path for the role | `string` | `"/"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | ARN of the policy to use as permissions boundary | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | Unique ID of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |
| <a name="output_role_path"></a> [role\_path](#output\_role\_path) | Path of the IAM role |
<!-- END_TF_DOCS -->