data "aws_ami" "this" {
  count       = var.use_dynamic_ami ? 1 : 0
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

locals {
  resolved_ami_id = var.use_dynamic_ami ? data.aws_ami.this[0].id : var.ami_id
  resolved_user_data = var.user_data_file != "" ? file(var.user_data_file) : var.user_data
}

resource "aws_instance" "this" {
  count         = var.use_launch_template ? 0 : var.instance_count
  ami           = local.resolved_ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name != "" ? var.key_name : null
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids       = var.security_group_ids
  user_data_base64             = local.resolved_user_data != "" ? base64encode(local.resolved_user_data) : null
  monitoring                   = var.enable_detailed_monitoring
  hibernation                  = var.enable_hibernation

  metadata_options {
    http_endpoint = var.metadata_http_endpoint
    http_tokens   = var.metadata_http_tokens
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_volume_iops != null ? var.root_volume_iops : null
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_volumes
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.volume_size
      volume_type = ebs_block_device.value.volume_type
      delete_on_termination = true
    }
  }

  tags = merge({
    Name = "${var.name}-${count.index + 1}"
  }, var.tags, try(var.instance_tags[count.index], {}))
}

resource "aws_eip" "this" {
  count = var.allocate_eip ? var.instance_count : 0
  instance = aws_instance.this[count.index].id

  tags = merge({
    Name = "${var.name}-eip-${count.index + 1}"
  }, var.tags)
}
