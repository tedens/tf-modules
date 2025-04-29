# Fetch current region (for REST invoke URL)
data "aws_region" "current" {}

# --- REST API (v1) ---
locals {
  rest_method_list = var.api_type == "REST" ? flatten([
    for r in var.rest_resources : [
      for m in r.methods : {
        path      = r.path
        method    = m
        integration = r.integration
        enable_cors = try(r.enable_cors, false)
      }
    ]
  ]) : []

  rest_method_map = var.api_type == "REST" ? {
    for item in local.rest_method_list :
    "${replace(item.path, "/", "")}-${item.method}" => item
  } : {}

  rest_cors_map = var.api_type == "REST" ? {
    for r in var.rest_resources : r.path => r if try(r.enable_cors, false)
  } : {}
}

resource "aws_api_gateway_rest_api" "rest" {
  count              = var.api_type == "REST" ? 1 : 0
  name               = var.name
  description        = var.description
  binary_media_types = var.binary_media_types
  tags               = var.tags
}

resource "aws_api_gateway_resource" "rest_resources" {
  for_each    = var.api_type == "REST" ? { for r in var.rest_resources : r.path => r } : {}
  rest_api_id = aws_api_gateway_rest_api.rest[0].id
  parent_id   = aws_api_gateway_rest_api.rest[0].root_resource_id
  path_part   = replace(each.key, "/", "")
}

resource "aws_api_gateway_method" "rest_methods" {
  for_each    = local.rest_method_map
  rest_api_id = aws_api_gateway_rest_api.rest[0].id
  resource_id = aws_api_gateway_resource.rest_resources[each.value.path].id
  http_method = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_integrations" {
  for_each = local.rest_method_map
  rest_api_id             = aws_api_gateway_rest_api.rest[0].id
  resource_id             = aws_api_gateway_resource.rest_resources[each.value.path].id
  http_method             = each.value.method
  type                    = each.value.integration.type
  uri                     = lookup(each.value.integration, "uri", null)
  integration_http_method = lookup(each.value.integration, "integration_http_method", null)
  credentials             = lookup(each.value.integration, "credentials", null)
}

resource "aws_api_gateway_method_response" "rest_cors" {
  for_each    = local.rest_cors_map
  rest_api_id = aws_api_gateway_rest_api.rest[0].id
  resource_id = aws_api_gateway_resource.rest_resources[each.key].id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "rest_cors" {
  for_each    = aws_api_gateway_method_response.rest_cors
  rest_api_id = aws_api_gateway_rest_api.rest[0].id
  resource_id = aws_api_gateway_resource.rest_resources[each.key].id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_deployment" "rest" {
  count       = var.api_type == "REST" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.rest[0].id
  triggers    = { redeploy = timestamp() }
}

resource "aws_api_gateway_stage" "rest" {
  count         = var.api_type == "REST" ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.rest[0].id
  deployment_id = aws_api_gateway_deployment.rest[0].id
  stage_name    = var.stage_name
  tags          = var.tags
}

# --- HTTP API (v2) ---
resource "aws_apigatewayv2_api" "http" {
  count         = var.api_type == "HTTP" ? 1 : 0
  name          = var.name
  protocol_type = "HTTP"
  description   = var.description
  
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "http" {
  for_each = var.api_type == "HTTP" ? { for r in var.http_routes : r.route_key => r } : {}
  api_id           = aws_apigatewayv2_api.http[0].id
  integration_type = "AWS_PROXY"
  integration_uri  = each.value.target_uri
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http" {
  for_each = aws_apigatewayv2_integration.http
  api_id    = aws_apigatewayv2_api.http[0].id
  route_key = each.key
  target    = "integrations/${each.value.id}"
}

resource "aws_apigatewayv2_stage" "http" {
  count       = var.api_type == "HTTP" ? 1 : 0
  api_id      = aws_apigatewayv2_api.http[0].id
  name        = var.stage_name
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = var.enable_logging
    logging_level            = var.log_level
  }

  tags = var.tags
}

# --- WebSocket API (v2) ---
resource "aws_apigatewayv2_api" "ws" {
  count                   = var.api_type == "WEBSOCKET" ? 1 : 0
  name                    = var.name
  protocol_type           = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "ws" {
  for_each = var.api_type == "WEBSOCKET" ? { for r in var.websocket_routes : r.route_key => r } : {}
  api_id           = aws_apigatewayv2_api.ws[0].id
  integration_type = "AWS_PROXY"
  integration_uri  = each.value.target_uri
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "ws" {
  for_each = aws_apigatewayv2_integration.ws
  api_id    = aws_apigatewayv2_api.ws[0].id
  route_key = each.key
  target    = "integrations/${each.value.id}"
}

resource "aws_apigatewayv2_stage" "ws" {
  count       = var.api_type == "WEBSOCKET" ? 1 : 0
  api_id      = aws_apigatewayv2_api.ws[0].id
  name        = var.stage_name
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = var.enable_logging
    logging_level            = var.log_level
  }

  tags = var.tags
}
