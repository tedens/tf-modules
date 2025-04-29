# Terraform AWS RDS Module

## Overview

This Terraform module provisions a fully customizable AWS RDS database instance.  
It supports MySQL, PostgreSQL, MariaDB, and Aurora engines, including Multi-AZ, encryption, IAM authentication, monitoring, backups, and more.

Designed to be **enterprise-ready** with secure defaults and full production flexibility.

---

## Features

- Supports MySQL, PostgreSQL, MariaDB, Aurora
- Multi-AZ deployments
- Storage autoscaling
- Encryption at rest with optional KMS key
- Backup window and retention management
- Maintenance window configuration
- IAM Database Authentication toggle
- Enhanced monitoring support
- Deletion protection
- Public or private endpoint control
- Full resource tagging

---

## Usage Examples

### 1. Simple Private RDS Instance (MySQL)

```hcl
module "rds_mysql" {
  source = "github.com/tedens/tf-modules//rds"

  identifier         = "example-mysql-db"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  username           = "admin"
  password           = "securepassword123"

  subnet_ids            = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.rds_sg.id]

  tags = {
    Project = "example"
    Owner   = "your-name"
  }
}
```

### 2. Highly Available Multi-AZ PostgreSQL with IAM Authentication

```hcl
module "rds_postgres_multi_az" {
  source = "github.com/tedens/tf-modules//rds"

  identifier         = "example-postgres-db"
  engine             = "postgres"
  engine_version     = "15.3"
  instance_class     = "db.m6g.large"
  username           = "admin"
  password           = "anothersecurepassword"

  multi_az            = true
  storage_encrypted   = true
  enable_iam_authentication = true

  subnet_ids            = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.rds_sg.id]

  backup_retention_period = 14
  backup_window           = "02:00-03:00"

  tags = {
    Project = "enterprise-db"
    Owner   = "your-name"
  }
}
```

### 3. Publicly Accessible RDS Instance with Custom KMS Key

```hcl
module "rds_public_postgres" {
  source = "github.com/tedens/tf-modules//rds"

  identifier         = "public-postgres-db"
  engine             = "postgres"
  engine_version     = "14.8"
  instance_class     = "db.t3.medium"
  username           = "admin"
  password           = "strongpassword"

  publicly_accessible = true
  kms_key_id           = aws_kms_key.rds_encryption_key.arn

  subnet_ids            = module.vpc.public_subnet_ids
  vpc_security_group_ids = [module.rds_public_sg.id]

  tags = {
    Project = "public-db"
    Owner   = "your-name"
  }
}
```

### 4. RDS Instance with Enhanced Monitoring

```hcl
module "rds_monitoring" {
  source = "github.com/tedens/tf-modules//rds"

  identifier         = "monitored-db"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.m5.large"
  username           = "admin"
  password           = "monitoringpassword"

  monitoring_interval = 60 # 60 seconds monitoring

  subnet_ids            = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.rds_monitoring_sg.id]

  tags = {
    Project = "monitored-db"
    Owner   = "your-name"
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
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Initial amount of allocated storage (GB) | `number` | `20` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply modifications immediately or during maintenance window | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain backups | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Preferred backup window | `string` | `"03:00-04:00"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protect the DB from accidental deletion | `bool` | `true` | no |
| <a name="input_enable_iam_authentication"></a> [enable\_iam\_authentication](#input\_enable\_iam\_authentication) | Enable IAM Database Authentication | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine (e.g., mysql, postgres, aurora-mysql) | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of the database engine | `string` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The name of the RDS instance | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class (e.g., db.t3.micro, db.m5.large) | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Optional KMS key for encryption | `string` | `""` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Preferred maintenance window | `string` | `"sun:05:00-sun:06:00"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum amount of allocated storage for autoscaling (GB) | `number` | `100` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Enhanced monitoring interval in seconds (0 to disable) | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to deploy Multi-AZ | `bool` | `false` | no |
| <a name="input_password"></a> [password](#input\_password) | Master password | `string` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the DB should have a public IP | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether to enable encryption at rest | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for DB subnet group | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Master username | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of VPC security group IDs to associate | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | ARN of the RDS instance |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | RDS instance endpoint |
| <a name="output_db_instance_identifier"></a> [db\_instance\_identifier](#output\_db\_instance\_identifier) | RDS instance identifier |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | Port number to connect to the database |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of the DB subnet group |
<!-- END_TF_DOCS -->