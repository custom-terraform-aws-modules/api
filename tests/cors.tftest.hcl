provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "duplicate_allow_methods" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"

    cors_config = {
      allow_methods = ["GET", "POST", "GET", "DELETE"]
      allow_origins = ["example.com"]
      allow_headers = ["Content-Type", "Authorization"]
    }
  }

  expect_failures = [var.cors_config]
}

run "duplicate_allow_origins" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"

    cors_config = {
      allow_methods = ["GET", "POST", "DELETE"]
      allow_origins = ["example.com", "test.com", "hello.org", "test.com"]
      allow_headers = ["Content-Type", "Authorization"]
    }
  }

  expect_failures = [var.cors_config]
}

run "duplicate_allow_headers" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"

    cors_config = {
      allow_methods = ["GET", "POST", "DELETE"]
      allow_origins = ["example.com"]
      allow_headers = ["Content-Type", "Authorization", "Content-Type"]
    }
  }

  expect_failures = [var.cors_config]
}

run "invalid_allow_methods" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"

    cors_config = {
      allow_methods = ["GET", "POST", "FOO", "DELETE"]
      allow_origins = ["example.com"]
      allow_headers = ["Content-Type", "Authorization"]
    }
  }

  expect_failures = [var.cors_config]
}

run "valid_cors_config" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"

    cors_config = {
      allow_methods = ["GET", "POST", "DELETE"]
      allow_origins = ["example.com"]
      allow_headers = ["Content-Type", "Authorization"]
    }
  }
}
