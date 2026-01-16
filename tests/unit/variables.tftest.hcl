# Unit tests for variable validation
# These tests use mock providers to validate input constraints without deploying resources

# -----------------------------------------------------------------------------
# Mock Provider Configuration
# -----------------------------------------------------------------------------
mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:root"
      user_id    = "AIDAEXAMPLE"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

# -----------------------------------------------------------------------------
# Test: bucket_name validation - DNS compliance
# -----------------------------------------------------------------------------
run "bucket_name_valid_simple" {
  command = plan

  variables {
    bucket_name = "my-valid-bucket"
    environment = "dev"
  }

  assert {
    condition     = var.bucket_name == "my-valid-bucket"
    error_message = "Valid bucket name should be accepted"
  }
}

run "bucket_name_valid_with_dots" {
  command = plan

  variables {
    bucket_name = "my.valid.bucket"
    environment = "dev"
  }

  assert {
    condition     = var.bucket_name == "my.valid.bucket"
    error_message = "Bucket name with dots should be accepted"
  }
}

run "bucket_name_invalid_uppercase" {
  command = plan

  variables {
    bucket_name = "My-Invalid-Bucket"
    environment = "dev"
  }

  expect_failures = [
    var.bucket_name
  ]
}

run "bucket_name_invalid_too_short" {
  command = plan

  variables {
    bucket_name = "ab"
    environment = "dev"
  }

  expect_failures = [
    var.bucket_name
  ]
}

run "bucket_name_invalid_starts_with_hyphen" {
  command = plan

  variables {
    bucket_name = "-invalid-bucket"
    environment = "dev"
  }

  expect_failures = [
    var.bucket_name
  ]
}

# -----------------------------------------------------------------------------
# Test: environment validation - allowed values
# -----------------------------------------------------------------------------
run "environment_valid_dev" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "dev"
  }

  assert {
    condition     = var.environment == "dev"
    error_message = "Environment 'dev' should be accepted"
  }
}

run "environment_valid_staging" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "staging"
  }

  assert {
    condition     = var.environment == "staging"
    error_message = "Environment 'staging' should be accepted"
  }
}

run "environment_valid_prod" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "prod"
  }

  assert {
    condition     = var.environment == "prod"
    error_message = "Environment 'prod' should be accepted"
  }
}

run "environment_valid_development" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "development"
  }

  assert {
    condition     = var.environment == "development"
    error_message = "Environment 'development' should be accepted"
  }
}

run "environment_valid_production" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "production"
  }

  assert {
    condition     = var.environment == "production"
    error_message = "Environment 'production' should be accepted"
  }
}

run "environment_invalid_value" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "invalid"
  }

  expect_failures = [
    var.environment
  ]
}

# -----------------------------------------------------------------------------
# Test: kms_key_arn validation - ARN format
# -----------------------------------------------------------------------------
run "kms_key_arn_valid" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "dev"
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }

  assert {
    condition     = var.kms_key_arn == "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    error_message = "Valid KMS key ARN should be accepted"
  }
}

run "kms_key_arn_null_creates_key" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "dev"
    kms_key_arn = null
  }

  # When kms_key_arn is null, the module should create a KMS key
  assert {
    condition     = var.kms_key_arn == null
    error_message = "Null KMS key ARN should be accepted (module will create key)"
  }
}

run "kms_key_arn_invalid_format" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "dev"
    kms_key_arn = "invalid-arn"
  }

  expect_failures = [
    var.kms_key_arn
  ]
}

# -----------------------------------------------------------------------------
# Test: logging validation - cross-variable dependency
# -----------------------------------------------------------------------------
run "logging_valid_with_bucket" {
  command = plan

  variables {
    bucket_name    = "test-bucket"
    environment    = "dev"
    enable_logging = true
    logging_bucket = "my-logging-bucket"
  }

  assert {
    condition     = var.enable_logging == true && var.logging_bucket == "my-logging-bucket"
    error_message = "Logging with bucket should be accepted"
  }
}

run "logging_disabled_no_bucket_needed" {
  command = plan

  variables {
    bucket_name    = "test-bucket"
    environment    = "dev"
    enable_logging = false
  }

  assert {
    condition     = var.enable_logging == false
    error_message = "Logging disabled should not require logging_bucket"
  }
}

# -----------------------------------------------------------------------------
# Test: lifecycle_rules validation
# -----------------------------------------------------------------------------
run "lifecycle_rules_empty_default" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "dev"
  }

  assert {
    condition     = length(var.lifecycle_rules) == 0
    error_message = "Default lifecycle_rules should be empty"
  }
}

run "lifecycle_rules_valid_single_rule" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "dev"
    lifecycle_rules = [
      {
        id      = "archive-rule"
        enabled = true
        prefix  = "data/"
        transitions = [
          {
            days          = 90
            storage_class = "GLACIER"
          }
        ]
      }
    ]
  }

  assert {
    condition     = length(var.lifecycle_rules) == 1
    error_message = "Single lifecycle rule should be accepted"
  }
}

# -----------------------------------------------------------------------------
# Test: website_configuration validation
# -----------------------------------------------------------------------------
run "website_config_valid_with_public_access_disabled" {
  command = plan

  variables {
    bucket_name             = "test-bucket"
    environment             = "dev"
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
    website_configuration = {
      index_document = "index.html"
      error_document = "error.html"
    }
  }

  assert {
    condition     = var.website_configuration != null
    error_message = "Website configuration with public access disabled should be accepted"
  }
}

# -----------------------------------------------------------------------------
# Test: kms_deletion_window_in_days validation
# -----------------------------------------------------------------------------
run "kms_deletion_window_valid_min" {
  command = plan

  variables {
    bucket_name                 = "test-bucket"
    environment                 = "dev"
    kms_deletion_window_in_days = 7
  }

  assert {
    condition     = var.kms_deletion_window_in_days == 7
    error_message = "KMS deletion window of 7 days should be accepted"
  }
}

run "kms_deletion_window_valid_max" {
  command = plan

  variables {
    bucket_name                 = "test-bucket"
    environment                 = "dev"
    kms_deletion_window_in_days = 30
  }

  assert {
    condition     = var.kms_deletion_window_in_days == 30
    error_message = "KMS deletion window of 30 days should be accepted"
  }
}

run "kms_deletion_window_invalid_below_min" {
  command = plan

  variables {
    bucket_name                 = "test-bucket"
    environment                 = "dev"
    kms_deletion_window_in_days = 6
  }

  expect_failures = [
    var.kms_deletion_window_in_days
  ]
}

run "kms_deletion_window_invalid_above_max" {
  command = plan

  variables {
    bucket_name                 = "test-bucket"
    environment                 = "dev"
    kms_deletion_window_in_days = 31
  }

  expect_failures = [
    var.kms_deletion_window_in_days
  ]
}
