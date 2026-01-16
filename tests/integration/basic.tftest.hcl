# Integration tests for basic secure bucket deployment
# These tests deploy real resources to verify functionality

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

provider "random" {}

# -----------------------------------------------------------------------------
# Variables for test runs
# -----------------------------------------------------------------------------
variables {
  test_bucket_prefix = "integration-test"
  test_environment   = "dev"
}

# -----------------------------------------------------------------------------
# Test: Basic secure bucket deployment
# -----------------------------------------------------------------------------
run "deploy_basic_secure_bucket" {
  command = apply

  variables {
    bucket_name = "${var.test_bucket_prefix}-${random_id.test_suffix.hex}"
    environment = var.test_environment
  }

  # Verify bucket was created
  assert {
    condition     = output.bucket_id != null && output.bucket_id != ""
    error_message = "Bucket ID should not be empty"
  }

  # Verify bucket ARN format
  assert {
    condition     = can(regex("^arn:aws:s3:::", output.bucket_arn))
    error_message = "Bucket ARN should be in valid format"
  }

  # Verify domain name
  assert {
    condition     = can(regex("\\.s3\\.amazonaws\\.com$", output.bucket_domain_name))
    error_message = "Bucket domain name should be in valid format"
  }

  # Verify KMS key was created (since we didn't provide one)
  assert {
    condition     = output.kms_key_arn != null
    error_message = "KMS key ARN should be created when not provided"
  }
}

# -----------------------------------------------------------------------------
# Helper resource for unique bucket names
# -----------------------------------------------------------------------------
resource "random_id" "test_suffix" {
  byte_length = 4
}
