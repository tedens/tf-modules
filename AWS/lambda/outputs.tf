output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN for the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_name" {
  description = "Name of the IAM role attached to the Lambda (if created)"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "role_arn" {
  description = "ARN of the IAM role attached to the Lambda (if created)"
  value       = var.create_role ? aws_iam_role.this[0].arn : null
}

output "log_group_name" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.this.name
}
