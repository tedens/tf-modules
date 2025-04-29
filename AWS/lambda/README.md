# Terraform AWS Lambda Module

## Overview

This Terraform module deploys an AWS Lambda function with full support for:

- Deployment via local ZIP, S3 artifact, or Docker container (ECR)
- IAM Role management (auto-create or supply your own)
- Environment variables
- VPC networking
- Dead Letter Queue (DLQ) configuration
- Layers
- Reserved concurrency
- CloudWatch log group with custom retention

Designed to be **enterprise-ready**, flexible, and production-secure.

---

## Features

- Deploy Lambda from:
  - Local ZIP file
  - S3 bucket + key
  - Docker container image (ECR)
- Create or attach an IAM role
- Pass secure environment variables
- Attach function to private VPCs
- Set memory, timeout, and concurrency limits
- Enable Dead Letter Queue for failure handling
- Attach Layers (shared libraries)
- Manage CloudWatch Logs with retention
- Fully tagged resources

---

## Usage Examples

### 1. Simple Lambda (Local ZIP)

```hcl
module "lambda_basic" {
  source = "github.com/tedens/tf-modules//lambda"

  function_name = "basic-lambda"
  runtime       = "python3.11"
  handler       = "index.handler"
  source_path   = "path/to/lambda.zip"

  tags = {
    Project = "basic-lambda"
  }
}
```

### 2. Lambda from Docker Image

```hcl
module "lambda_docker" {
  source = "github.com/tedens/tf-modules//lambda"

  function_name = "docker-lambda"
  image_uri     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda-image:latest"

  memory_size = 512
  timeout     = 10

  tags = {
    Project = "docker-lambda"
  }
}
```

### 3. Lambda with Custom IAM Role and Environment Vars

```hcl
module "lambda_custom_iam" {
  source = "github.com/tedens/tf-modules//lambda"

  function_name = "lambda-custom-iam"
  runtime       = "nodejs18.x"
  handler       = "app.handler"
  source_path   = "path/to/app.zip"

  role_arn = aws_iam_role.custom_lambda_role.arn

  environment_variables = {
    ENVIRONMENT = "production"
    API_KEY     = "super-secret"
  }

  tags = {
    Project = "custom-iam"
  }
}
```

### 4. Lambda with VPC Configuration

```hcl
module "lambda_vpc" {
  source = "github.com/tedens/tf-modules//lambda"

  function_name = "vpc-lambda"
  runtime       = "python3.11"
  handler       = "index.handler"
  source_path   = "path/to/vpc-lambda.zip"

  vpc_subnet_ids         = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.lambda_sg.id]

  tags = {
    Project = "vpc-lambda"
  }
}
```

# 5. Lambda with DLQ and Layers

```hcl
module "lambda_advanced" {
  source = "github.com/tedens/tf-modules//lambda"

  function_name = "advanced-lambda"
  runtime       = "python3.11"
  handler       = "index.handler"
  source_path   = "path/to/advanced.zip"

  dead_letter_target_arn = aws_sqs_queue.dlq.arn

  layers = [
    "arn:aws:lambda:us-east-1:123456789012:layer:my-shared-layer:1"
  ]

  reserved_concurrent_executions = 5

  tags = {
    Project = "advanced-lambda"
  }
}
```

<!-- BEGIN_TF_DOCS:inputs --> <!-- END_TF_DOCS:inputs --> 
<!-- BEGIN_TF_DOCS:outputs --> <!-- END_TF_DOCS:outputs --> 
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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Create a basic execution IAM Role | `bool` | `true` | no |
| <a name="input_dead_letter_target_arn"></a> [dead\_letter\_target\_arn](#input\_dead\_letter\_target\_arn) | ARN of SQS queue or SNS topic for failed executions | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Lambda function | `string` | `""` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the function | `map(string)` | `{}` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Lambda function handler (e.g., index.handler) | `string` | n/a | yes |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR Image URI for the Lambda function (for container-based deployment) | `string` | `""` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | List of Lambda layer ARNs | `list(string)` | `[]` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Retention period for CloudWatch logs | `number` | `14` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB | `number` | `128` | no |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | Package type for the Lambda function (Zip or Image) | `string` | `"Zip"` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Reserved concurrency limit | `number` | `-1` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM Role ARN to attach to the Lambda (optional, otherwise auto-created) | `string` | `""` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda runtime (e.g., nodejs18.x, python3.11) | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket for Lambda deployment package (optional) | `string` | `""` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key for Lambda deployment package (optional) | `string` | `""` | no |
| <a name="input_source_path"></a> [source\_path](#input\_source\_path) | Path to local ZIP file or directory | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in seconds | `number` | `3` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs for VPC access | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of subnet IDs for VPC access | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN for the Lambda function |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | CloudWatch Log Group name |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role attached to the Lambda (if created) |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role attached to the Lambda (if created) |
<!-- END_TF_DOCS -->