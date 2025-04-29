output "instance_ids" {
  description = "IDs of the launched EC2 instances"
  value       = aws_instance.this[*].id
}

output "instance_public_ips" {
  description = "Public IPs of the instances (if assigned)"
  value       = aws_instance.this[*].public_ip
}

output "instance_private_ips" {
  description = "Private IPs of the instances"
  value       = aws_instance.this[*].private_ip
}

output "elastic_ips" {
  description = "Elastic IP addresses (if allocated)"
  value       = aws_eip.this[*].public_ip
}

