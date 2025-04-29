# Terraform AWS API Gateway Module

## Overview

This Terraform module provisions an AWS API Gateway with support for:

- REST API (v1) with method/integration/CORS mapping
- HTTP API (v2) with route and integration support
- WebSocket API (v2) with route mapping and Lambda targets
- Logging, tagging, and stage configuration
- Clean input-driven structure

Designed to be **enterprise-ready**, dynamic, and easily extendable.

---

## Features

- Choose between `REST`, `HTTP`, or `WEBSOCKET` using `api_type`
- Dynamic resource/method mapping for REST APIs
- Route-to-target definition for HTTP and WebSocket APIs
- CORS support for REST and HTTP APIs
- CloudWatch logging and metrics support
- Full tagging for all resources
- Modular deployment and stage creation

---

## Usage Examples

### 1. REST API (v1) with Lambda Integration and CORS

```hcl
module "api_gateway_rest" {
  source    = "github.com/tedens/tf-modules//apigateway"
  api_type  = "REST"
  name      = "rest-api"
  stage_name = "prod"

  rest_resources = [
    {
      path = "/users"
      methods = ["GET", "POST"]
      integration = {
        type                    = "AWS_PROXY"
        uri                     = aws_lambda_function.users.invoke_arn
        integration_http_method = "POST"
      }
      enable_cors = true
    }
  ]

  binary_media_types = ["image/png", "application/octet-stream"]
  enable_logging     = true
  log_level          = "INFO"

  tags = {
    Project = "api-rest"
  }
}
```

---

### 2. HTTP API (v2) with Lambda Integration

```hcl
module "api_gateway_http" {
  source    = "github.com/tedens/tf-modules//apigateway"
  api_type  = "HTTP"
  name      = "http-api"
  stage_name = "v1"

  http_routes = [
    {
      route_key  = "GET /status"
      target_uri = aws_lambda_function.status.invoke_arn
    },
    {
      route_key  = "POST /submit"
      target_uri = aws_lambda_function.submit.invoke_arn
    }
  ]

  http_cors_configuration = {
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["*"]
    allow_credentials = true
  }

  enable_logging = true
  log_level      = "INFO"

  tags = {
    Project = "api-http"
  }
}
```

---

### 3. WebSocket API (v2) with Custom Routes

```hcl
module "api_gateway_ws" {
  source    = "github.com/tedens/tf-modules//apigateway"
  api_type  = "WEBSOCKET"
  name      = "ws-api"
  stage_name = "live"

  websocket_routes = [
    {
      route_key  = "$connect"
      target_uri = aws_lambda_function.ws_connect.invoke_arn
    },
    {
      route_key  = "$disconnect"
      target_uri = aws_lambda_function.ws_disconnect.invoke_arn
    },
    {
      route_key  = "sendMessage"
      target_uri = aws_lambda_function.ws_send_message.invoke_arn
    }
  ]

  enable_logging = true
  log_level      = "INFO"

  tags = {
    Project = "api-websocket"
  }
}
```

---

## Terraform Inputs and Outputs

<!-- BEGIN_TF_DOCS:inputs -->
<!-- END_TF_DOCS:inputs -->

<!-- BEGIN_TF_DOCS:outputs -->
<!-- END_TF_DOCS:outputs -->

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
| [aws_api_gateway_deployment.rest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.rest_integrations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.rest_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.rest_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.rest_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.rest_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.rest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.rest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_apigatewayv2_api.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_api.ws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_integration.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_integration.ws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_route.ws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_apigatewayv2_stage.ws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_type"></a> [api\_type](#input\_api\_type) | Type of API Gateway: REST, HTTP, or WEBSOCKET | `string` | `"REST"` | no |
| <a name="input_binary_media_types"></a> [binary\_media\_types](#input\_binary\_media\_types) | REST API only: list of binary media types | `list(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the API | `string` | `""` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging on stages | `bool` | `false` | no |
| <a name="input_http_cors_configuration"></a> [http\_cors\_configuration](#input\_http\_cors\_configuration) | Optional CORS config for HTTP API v2 (api\_type = "HTTP") | <pre>object({<br/>    allow_origins     = list(string)<br/>    allow_methods     = list(string)<br/>    allow_headers     = list(string)<br/>    expose_headers    = optional(list(string))<br/>    max_age           = optional(number)<br/>    allow_credentials = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_http_routes"></a> [http\_routes](#input\_http\_routes) | HTTP API v2 routes (only used when api\_type = "HTTP"). Each: { route\_key, target\_uri } | <pre>list(object({<br/>    route_key  = string      # e.g. "GET /users"<br/>    target_uri = string      # lambda ARN or HTTP URL<br/>  }))</pre> | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level (INFO, ERROR, or OFF) | `string` | `"INFO"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the API Gateway | `string` | n/a | yes |
| <a name="input_rest_resources"></a> [rest\_resources](#input\_rest\_resources) | REST API resources (only used when api\_type = "REST"). Each: { path, methods, integration, enable\_cors } | <pre>list(object({<br/>    path        = string<br/>    methods     = list(string)<br/>    integration = object({<br/>      type                    = string                      # MOCK | AWS | HTTP | AWS_PROXY<br/>      uri                     = optional(string)            # for AWS, HTTP<br/>      integration_http_method = optional(string)            # for HTTP/AWS<br/>      credentials             = optional(string)            # IAM role ARN<br/>    })<br/>    enable_cors = optional(bool)                           # whether to expose OPTIONS/CORS<br/>  }))</pre> | `[]` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the deployment stage | `string` | `"dev"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all created resources | `map(string)` | `{}` | no |
| <a name="input_websocket_routes"></a> [websocket\_routes](#input\_websocket\_routes) | WebSocket API v2 routes (only used when api\_type = "WEBSOCKET"). Each: { route\_key, target\_uri } | <pre>list(object({<br/>    route_key  = string      # e.g. "$connect", "$disconnect"<br/>    target_uri = string      # lambda ARN<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_api_endpoint"></a> [http\_api\_endpoint](#output\_http\_api\_endpoint) | HTTP API v2 endpoint URL |
| <a name="output_http_api_id"></a> [http\_api\_id](#output\_http\_api\_id) | HTTP API v2 ID (only when api\_type = HTTP) |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | REST API ID (only when api\_type = REST) |
| <a name="output_rest_invoke_url"></a> [rest\_invoke\_url](#output\_rest\_invoke\_url) | REST API invoke URL |
| <a name="output_websocket_api_endpoint"></a> [websocket\_api\_endpoint](#output\_websocket\_api\_endpoint) | WebSocket API v2 endpoint URL |
| <a name="output_websocket_api_id"></a> [websocket\_api\_id](#output\_websocket\_api\_id) | WebSocket API v2 ID (only when api\_type = WEBSOCKET) |
<!-- END_TF_DOCS -->