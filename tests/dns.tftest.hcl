provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "base_domain_split_without_sub_domain" {
  command = plan

  variables {
    test       = true
    identifier = "abc"
    domain     = "test.com"
  }

  assert {
    condition     = local.base_domain == "test.com"
    error_message = "Base domain split failed, wanted: 'test.com', got: ${local.base_domain}"
  }
}

run "base_domain_split_with_single_sub_domain" {
  command = plan

  variables {
    test       = true
    identifier = "abc"
    domain     = "www.test.com"
  }

  assert {
    condition     = local.base_domain == "test.com"
    error_message = "Base domain split failed, wanted: 'test.com', got: ${local.base_domain}"
  }
}

run "base_domain_split_with_multiple_sub_domain" {
  command = plan

  variables {
    test       = true
    identifier = "abc"
    domain     = "www.blog.api.test.com"
  }

  assert {
    condition     = local.base_domain == "test.com"
    error_message = "Base domain split failed, wanted: 'test.com', got: ${local.base_domain}"
  }
}
