variable "api_type" {
  description = "Type of API Gateway: REST, HTTP, or WEBSOCKET"
  type        = string
  default     = "REST"
  validation {
    condition     = contains(["REST","HTTP","WEBSOCKET"], var.api_type)
    error_message = "api_type must be one of REST, HTTP, or WEBSOCKET"
  }
}

variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "description" {
  description = "Description of the API"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "Name of the deployment stage"
  type        = string
  default     = "dev"
}

variable "rest_resources" {
  description = "REST API resources (only used when api_type = \"REST\"). Each: { path, methods, integration, enable_cors }"
  type = list(object({
    path        = string
    methods     = list(string)
    integration = object({
      type                    = string                      # MOCK | AWS | HTTP | AWS_PROXY
      uri                     = optional(string)            # for AWS, HTTP
      integration_http_method = optional(string)            # for HTTP/AWS
      credentials             = optional(string)            # IAM role ARN
    })
    enable_cors = optional(bool)                           # whether to expose OPTIONS/CORS
  }))
  default = []
}

variable "binary_media_types" {
  description = "REST API only: list of binary media types"
  type        = list(string)
  default     = []
}

variable "http_routes" {
  description = "HTTP API v2 routes (only used when api_type = \"HTTP\"). Each: { route_key, target_uri }"
  type = list(object({
    route_key  = string      # e.g. "GET /users"
    target_uri = string      # lambda ARN or HTTP URL
  }))
  default = []
}

variable "http_cors_configuration" {
  description = "Optional CORS config for HTTP API v2 (api_type = \"HTTP\")"
  type = object({
    allow_origins     = list(string)
    allow_methods     = list(string)
    allow_headers     = list(string)
    expose_headers    = optional(list(string))
    max_age           = optional(number)
    allow_credentials = optional(bool)
  })
  default = null
}

variable "websocket_routes" {
  description = "WebSocket API v2 routes (only used when api_type = \"WEBSOCKET\"). Each: { route_key, target_uri }"
  type = list(object({
    route_key  = string      # e.g. "$connect", "$disconnect"
    target_uri = string      # lambda ARN
  }))
  default = []
}

variable "enable_logging" {
  description = "Whether to enable CloudWatch logging on stages"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Log level (INFO, ERROR, or OFF)"
  type        = string
  default     = "INFO"
}

variable "tags" {
  description = "Tags to apply to all created resources"
  type        = map(string)
  default     = {}
}
