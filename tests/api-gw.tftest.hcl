provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "invalid_identifier" {
  command = plan

  variables {
    identifier = "ab"
    domain     = "test.com"
    zone_id    = "test-zone"
  }

  expect_failures = [var.identifier]
}

run "valid_identifier" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
  }
}

run "invalid_route_method" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    routes = [
      {
        route        = "/test"
        method       = "GET"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "FOO"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "DELETE"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      }
    ]
  }

  expect_failures = [var.routes]
}

run "duplicate_route" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    routes = [
      {
        route        = "/test"
        method       = "GET"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "DELETE"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "GET"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      }
    ]
  }

  expect_failures = [var.routes]
}

run "invalid_route_function_arn" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    routes = [
      {
        route        = "/test"
        method       = "GET"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "DELETE"
        function_arn = "arn:aws:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "POST"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      }
    ]
  }

  expect_failures = [var.routes]
}

run "valid_routes" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    routes = [
      {
        route        = "/test"
        method       = "GET"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "DELETE"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "POST"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      }
    ]
  }
}

run "invalid_log_config" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    log_config = {
      retention_in_days = 200
    }
  }

  expect_failures = [var.log_config]
}

run "invalid_route_invoke_arn" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    routes = [
      {
        route        = "/test"
        method       = "GET"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "DELETE"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:api:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      },
      {
        route        = "/test"
        method       = "POST"
        function_arn = "arn:aws:lambda:test"
        invoke_arn   = "arn:aws:apigateway:test"
        burst_limit  = 1000
        rate_limit   = 0.01
      }
    ]
  }

  expect_failures = [var.routes]
}

run "valid_log_config" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    log_config = {
      retention_in_days = 7
    }
  }
}
