provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "with_web_acl" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    rate_limit = 100
  }

  assert {
    condition     = length(aws_wafv2_web_acl.main) == 1
    error_message = "Web ACL was not created"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_association.main) == 1
    error_message = "Web ACL association was not created"
  }
}

run "without_web_acl" {
  command = plan

  variables {
    identifier = "abc"
    domain     = "test.com"
    zone_id    = "test-zone"
    rate_limit = 0
  }

  assert {
    condition     = length(aws_wafv2_web_acl.main) == 0
    error_message = "Web ACL was created unexpectedly"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_association.main) == 0
    error_message = "Web ACL association was created unexpectedly"
  }
}
