variable "identifier" {
  description = "Unique identifier to differentiate global resources."
  type        = string
  validation {
    condition     = length(var.identifier) > 2
    error_message = "Identifier must be at least 3 characters"
  }
}

variable "description" {
  description = "Short text of what the API Gateway is trying to accomplish."
  type        = string
  default     = ""
}

variable "domain" {
  description = "Custom domain pointed to the API Gateway."
  type        = string
}

variable "log_config" {
  description = "An object for the definition of a CloudWatch log for the API Gateway."
  type = object({
    retention_in_days = number
  })
  default = null
  validation {
    condition = try(var.log_config["retention_in_days"], 1) == 1 || (
      try(var.log_config["retention_in_days"], 3) == 3) || (
      try(var.log_config["retention_in_days"], 5) == 5) || (
      try(var.log_config["retention_in_days"], 7) == 7) || (
      try(var.log_config["retention_in_days"], 14) == 14) || (
      try(var.log_config["retention_in_days"], 30) == 30) || (
      try(var.log_config["retention_in_days"], 365) == 365) || (
    try(var.log_config["retention_in_days"], 0) == 0)
    error_message = "Retention in days must be one of these values: 0, 1, 3, 5, 7, 14, 30, 365"
  }
}

variable "cors_config" {
  description = "An object for the definition of the CORS configuration for the API Gateway."
  type = object({
    allow_methods = list(string)
    allow_origins = list(string)
    allow_headers = list(string)
  })
  default = null
  validation {
    condition     = length(toset(try(var.cors_config["allow_methods"], []))) == length(try(var.cors_config["allow_methods"], []))
    error_message = "Allowed methods must be unique"
  }
  validation {
    condition     = length(toset(try(var.cors_config["allow_origins"], []))) == length(try(var.cors_config["allow_origins"], []))
    error_message = "Allowed origins must be unique"
  }
  validation {
    condition     = length(toset(try(var.cors_config["allow_headers"], []))) == length(try(var.cors_config["allow_headers"], []))
    error_message = "Allowed headers must be unique"
  }
  validation {
    condition = !contains([for v in try(var.cors_config["allow_methods"], []) :
      v == "GET" || v == "POST" || v == "DELETE" || v == "PUT" || v == "PATCH" ||
    v == "OPTIONS" || v == "HEAD" || v == "CONNECT" || v == "TRACE"], false)
    error_message = "Allowed methods must be one of these values: 'GET', 'POST', 'DELETE', 'PUT', 'PATCH', 'OPTIONS', 'HEAD', 'CONNECT', 'TRACE'"
  }
}

variable "routes" {
  description = "A list of objects for the definition of routes in the API Gateway."
  type = list(object({
    route        = string
    method       = string
    function_arn = string
    invoke_arn   = string
    burst_limit  = number
    rate_limit   = number
  }))
  default = []
  validation {
    condition = !contains([for v in var.routes :
      try(v["method"], null) == "GET" || try(v["method"], null) == "POST" || try(v["method"], null) == "DELETE" ||
      try(v["method"], null) == "PUT" || try(v["method"], null) == "PATCH" || try(v["method"], null) == "OPTIONS" ||
    try(v["method"], null) == "HEAD" || try(v["method"], null) == "CONNECT" || try(v["method"], null) == "TRACE"], false)
    error_message = "Route methods must be one of these values: 'GET', 'POST', 'DELETE', 'PUT', 'PATCH', 'OPTIONS', 'HEAD', 'CONNECT', 'TRACE'"
  }
  validation {
    condition     = length(toset([for v in var.routes : "${try(v["method"], null)} ${try(v["route"], null)}"])) == length(var.routes)
    error_message = "Route path with route method must be unique"
  }
  validation {
    condition     = !contains([for v in var.routes : startswith(try(v["function_arn"], null), "arn:aws:lambda:")], false)
    error_message = "Function ARN of routes must be valid"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "test" {
  description = "A flag for wether or not creating a test environment to conduct unit tests with."
  type        = bool
  default     = false
}
