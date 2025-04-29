output "rest_api_id" {
  description = "REST API ID (only when api_type = REST)"
  value       = var.api_type == "REST" ? aws_api_gateway_rest_api.rest[0].id : null
}

output "rest_invoke_url" {
  description = "REST API invoke URL"
  value       = var.api_type == "REST" ? "https://${aws_api_gateway_rest_api.rest[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}" : null
}

output "http_api_id" {
  description = "HTTP API v2 ID (only when api_type = HTTP)"
  value       = var.api_type == "HTTP" ? aws_apigatewayv2_api.http[0].id : null
}

output "http_api_endpoint" {
  description = "HTTP API v2 endpoint URL"
  value       = var.api_type == "HTTP" ? aws_apigatewayv2_api.http[0].api_endpoint : null
}

output "websocket_api_id" {
  description = "WebSocket API v2 ID (only when api_type = WEBSOCKET)"
  value       = var.api_type == "WEBSOCKET" ? aws_apigatewayv2_api.ws[0].id : null
}

output "websocket_api_endpoint" {
  description = "WebSocket API v2 endpoint URL"
  value       = var.api_type == "WEBSOCKET" ? aws_apigatewayv2_api.ws[0].api_endpoint : null
}

# helper for REST URL
data "aws_region" "current" {}
