# Terraform AWS EC2 Module

## Overview

This Terraform module provisions one or more highly-configurable EC2 instances on AWS.  
It supports optional Elastic IPs, IAM roles, custom EBS volumes, detailed monitoring, dynamic AMI lookup, and more.

Designed to cover **every common EC2 deployment scenario** with safe defaults for easy launches.

---

## Features

- Launch single or multiple EC2 instances
- Elastic IP allocation and association (optional)
- Dynamic AMI lookup (no hardcoding AMI IDs)
- Optional detailed monitoring and hibernation
- Root and additional EBS volumes (dynamic)
- User data via inline script or external file
- IAM Instance Profile attachment
- Metadata Options (IMDSv2 hardened by default)
- Per-instance custom tags
- Launch Template stub ready for future support
- Lifecycle management (`prevent_destroy` toggle)

---

## Usage Example

```hcl
module "ec2" {
  source = "github.com/tedens/tf-modules//ec2"

  name               = "appserver"
  instance_count     = 2
  instance_type      = "t3.small"
  subnet_id          = module.vpc.private_subnet_ids[0]
  security_group_ids = [module.security_group.id]
  key_name           = "your-ssh-key"
  
  # Use dynamic AMI lookup
  use_dynamic_ami    = true
  ami_name_filter    = "amzn2-ami-hvm-*-x86_64-gp2"
  ami_owners         = ["amazon"]

  iam_instance_profile = "ec2-instance-role"

  root_volume_size   = 20
  root_volume_type   = "gp3"

  ebs_volumes = [
    {
      device_name = "/dev/sdf"
      volume_size = 100
      volume_type = "gp3"
    }
  ]

  enable_detailed_monitoring = true
  enable_hibernation         = false

  allocate_eip = true

  user_data_file = "${path.module}/user-data.sh"

  tags = {
    Project = "example"
    Owner   = "your-name"
  }

  instance_tags = [
    { Role = "web" },
    { Role = "worker" }
  ]
}


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
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocate_eip"></a> [allocate\_eip](#input\_allocate\_eip) | Allocate Elastic IP(s) and associate | `bool` | `false` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID to use, unless dynamic AMI is enabled | `string` | `""` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | Filter string for dynamic AMI lookup | `string` | `"amzn2-ami-hvm-*-x86_64-gp2"` | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | Owners list for dynamic AMI lookup | `list(string)` | <pre>[<br/>  "amazon"<br/>]</pre> | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP | `bool` | `true` | no |
| <a name="input_ebs_volumes"></a> [ebs\_volumes](#input\_ebs\_volumes) | n/a | <pre>list(object({<br/>    device_name = string<br/>    volume_size = number<br/>    volume_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring) | Enable detailed monitoring | `bool` | `false` | no |
| <a name="input_enable_hibernation"></a> [enable\_hibernation](#input\_enable\_hibernation) | Enable instance hibernation | `bool` | `false` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM instance profile name | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of EC2 instances to launch | `number` | `1` | no |
| <a name="input_instance_tags"></a> [instance\_tags](#input\_instance\_tags) | List of tag maps per instance index | `list(map(string))` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key name | `string` | `""` | no |
| <a name="input_metadata_http_endpoint"></a> [metadata\_http\_endpoint](#input\_metadata\_http\_endpoint) | IMDS endpoint setting | `string` | `"enabled"` | no |
| <a name="input_metadata_http_tokens"></a> [metadata\_http\_tokens](#input\_metadata\_http\_tokens) | IMDSv2 http\_tokens setting (optional) | `string` | `"required"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for the EC2 instances | `string` | n/a | yes |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Prevent instance destruction | `bool` | `false` | no |
| <a name="input_root_volume_iops"></a> [root\_volume\_iops](#input\_root\_volume\_iops) | n/a | `number` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | n/a | `number` | `8` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | n/a | `string` | `"gp3"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of SGs to attach | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to launch instance into | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Base tags for all resources | `map(string)` | `{}` | no |
| <a name="input_use_dynamic_ami"></a> [use\_dynamic\_ami](#input\_use\_dynamic\_ami) | Enable dynamic AMI lookup using filters | `bool` | `false` | no |
| <a name="input_use_launch_template"></a> [use\_launch\_template](#input\_use\_launch\_template) | Use a launch template instead of direct aws\_instance | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Inline user data script | `string` | `""` | no |
| <a name="input_user_data_file"></a> [user\_data\_file](#input\_user\_data\_file) | Path to file with user data (overrides inline) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elastic_ips"></a> [elastic\_ips](#output\_elastic\_ips) | Elastic IP addresses (if allocated) |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the launched EC2 instances |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | Private IPs of the instances |
| <a name="output_instance_public_ips"></a> [instance\_public\_ips](#output\_instance\_public\_ips) | Public IPs of the instances (if assigned) |
<!-- END_TF_DOCS -->