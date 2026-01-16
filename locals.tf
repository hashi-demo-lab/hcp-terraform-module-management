# -----------------------------------------------------------------------------
# Tag Management
# -----------------------------------------------------------------------------

locals {
  # Default tags applied to all taggable resources
  # TFLint requires: Application, Environment, ManagedBy
  default_tags = {
    Application = "terraform-aws-s3"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Merged tags: default tags + user-provided tags
  # User tags override default tags if there are conflicts
  tags = merge(local.default_tags, var.tags)
}

# -----------------------------------------------------------------------------
# KMS Key Resolution
# -----------------------------------------------------------------------------

locals {
  # Determine whether to create a KMS key
  create_kms_key = var.kms_key_arn == null

  # Resolve the effective KMS key ARN
  # Uses provided ARN if available, otherwise uses module-created key
  kms_key_arn = local.create_kms_key ? aws_kms_key.this[0].arn : var.kms_key_arn

  # Extract KMS key ID from ARN
  # Format: arn:aws:kms:region:account:key/key-id
  kms_key_id = local.create_kms_key ? aws_kms_key.this[0].key_id : element(split("/", var.kms_key_arn), length(split("/", var.kms_key_arn)) - 1)
}

# -----------------------------------------------------------------------------
# Cross-Variable Validation (FR-009: Logging Requires Bucket)
# -----------------------------------------------------------------------------

locals {
  # Validate that logging_bucket is provided when enable_logging is true
  validate_logging = (
    var.enable_logging && var.logging_bucket == null
    ? tobool("ERROR: logging_bucket is required when enable_logging is true")
    : true
  )
}

# -----------------------------------------------------------------------------
# Cross-Variable Validation (FR-013a: Website Requires Public Access Disabled)
# -----------------------------------------------------------------------------

locals {
  # Validate that all public access blocks are disabled for website hosting
  validate_website = (
    var.website_configuration != null && (
      var.block_public_acls ||
      var.block_public_policy ||
      var.ignore_public_acls ||
      var.restrict_public_buckets
    )
    ? tobool("ERROR: All public access blocks must be disabled when website_configuration is provided (block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets must all be false)")
    : true
  )
}

# -----------------------------------------------------------------------------
# Resource Creation Flags
# -----------------------------------------------------------------------------

locals {
  # Logging configuration is created when explicitly enabled
  create_logging = var.enable_logging && var.logging_bucket != null

  # Lifecycle configuration is created when rules are provided
  create_lifecycle = length(var.lifecycle_rules) > 0

  # Website configuration is created when configuration is provided
  create_website = var.website_configuration != null
}
