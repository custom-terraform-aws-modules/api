################################
# Route53                      #
################################

locals {
  sub_strings = split(".", var.domain)
  base_domain = "${local.sub_strings[length(local.sub_strings) - 2]}.${local.sub_strings[length(local.sub_strings) - 1]}"
}

# get public zone for base domain (must be already present in account)
data "aws_route53_zone" "main" {
  count        = length(var.zone_id) < 1 ? 1 : 0
  name         = local.base_domain
  private_zone = false
}

# conditionally set the zone_id to avoid duplication of conditions
locals {
  zone_id = length(var.zone_id) < 1 ? data.aws_route53_zone.main[0].id : var.zone_id
}

resource "aws_acm_certificate" "main" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

################################
# CloudWatch                   #
################################

resource "aws_cloudwatch_log_group" "main" {
  count             = var.log_config != null ? 1 : 0
  name              = "${var.identifier}-api-gw"
  retention_in_days = try(var.log_config["retention_in_days"], null)

  tags = var.tags
}

################################
# API Gateway                  #
################################

resource "aws_apigatewayv2_domain_name" "main" {
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.main.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.tags
}

resource "aws_apigatewayv2_api" "main" {
  name          = var.identifier
  description   = var.description
  protocol_type = "HTTP"

  dynamic "cors_configuration" {
    for_each = var.cors_config != null ? [1] : []
    content {
      allow_methods = try(var.cors_config["allow_methods"], null)
      allow_origins = try(var.cors_config["allow_origins"], null)
      allow_headers = try(var.cors_config["allow_headers"], null)
    }
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "main" {
  count              = length(var.routes)
  api_id             = aws_apigatewayv2_api.main.id
  integration_uri    = try(var.routes[count.index]["invoke_arn"], null)
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "main" {
  count     = length(var.routes)
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "${try(var.routes[count.index]["method"], null)} ${try(var.routes[count.index]["route"], null)}"
  target    = "integrations/${aws_apigatewayv2_integration.main[count.index].id}"
}

resource "aws_lambda_permission" "main" {
  count         = length(var.routes)
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = try(var.routes[count.index]["function_arn"], null)
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*${try(var.routes[count.index]["route"], null)}"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  dynamic "route_settings" {
    for_each = var.routes

    content {
      route_key              = "${try(route_settings.value["method"], null)} ${try(route_settings.value["route"], null)}"
      throttling_burst_limit = try(route_settings.value["burst_limit"], null)
      throttling_rate_limit  = try(route_settings.value["rate_limit"], null)
    }
  }

  dynamic "access_log_settings" {
    for_each = var.log_config != null ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.main[0].arn

      format = jsonencode({
        requestId               = "$context.requestId"
        sourceIp                = "$context.identity.sourceIp"
        requestTime             = "$context.requestTime"
        protocol                = "$context.protocol"
        httpMethod              = "$context.httpMethod"
        resourcePath            = "$context.resourcePath"
        routeKey                = "$context.routeKey"
        status                  = "$context.status"
        responseLength          = "$context.responseLength"
        integrationErrorMessage = "$context.integrationErrorMessage"
        }
      )
    }
  }

  tags = var.tags
}

resource "aws_apigatewayv2_api_mapping" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.main.id
  stage       = aws_apigatewayv2_stage.main.id
}

# point domain to API Gateway DNS name
resource "aws_route53_record" "main" {
  name    = var.domain
  type    = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
