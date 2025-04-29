# Create DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge({
    Name = "${var.identifier}-subnet-group"
  }, var.tags)
}

# Create RDS DB Instance
resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  username = var.username
  password = var.password

  publicly_accessible = var.publicly_accessible
  multi_az            = var.multi_az

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.this.name

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  iam_database_authentication_enabled = var.enable_iam_authentication

  monitoring_interval = var.monitoring_interval

  deletion_protection = var.deletion_protection

  apply_immediately = var.apply_immediately

  tags = merge({
    Name = var.identifier
  }, var.tags)
}
