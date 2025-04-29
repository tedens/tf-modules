# Create IAM Role if needed
resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = var.tags
}

# Attach basic AWSLambdaBasicExecutionRole policy
resource "aws_iam_role_policy_attachment" "basic_execution" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}

# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description

  # Code deployment logic
  filename         = var.image_uri == "" && var.source_path != "" ? var.source_path : null
  s3_bucket        = var.image_uri == "" && var.s3_bucket != "" ? var.s3_bucket : null
  s3_key           = var.image_uri == "" && var.s3_key != "" ? var.s3_key : null
  image_uri        = var.image_uri != "" ? var.image_uri : null

  role             = var.create_role ? aws_iam_role.this[0].arn : var.role_arn
  handler          = var.image_uri == "" ? var.handler : null
  runtime          = var.image_uri == "" ? var.runtime : null
  timeout          = var.timeout
  memory_size      = var.memory_size

  layers = var.layers

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  dead_letter_config {
    target_arn = var.dead_letter_target_arn != "" ? var.dead_letter_target_arn : null
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions >= 0 ? var.reserved_concurrent_executions : null

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}
