# Complete example: S3 bucket with all optional features
# This example demonstrates all optional features including:
# - Custom KMS key (BYOK)
# - Access logging
# - Lifecycle rules
# - Website hosting (with public access)

# Example 1: Full-featured secure bucket (no website)
module "data_bucket" {
  source = "../.."

  bucket_name       = "example-data-bucket-${random_id.suffix.hex}"
  environment       = "prod"
  enable_versioning = true

  # Enable access logging
  enable_logging = true
  logging_bucket = aws_s3_bucket.logs.id
  logging_prefix = "data-bucket-logs/"

  # Lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      id      = "archive-old-data"
      enabled = true
      prefix  = "data/"

      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        noncurrent_days = 30
      }

      abort_incomplete_multipart_upload_days = 7
    }
  ]

  tags = {
    Project = "DataPlatform"
    Owner   = "platform-team"
  }
}

# Example 2: Static website bucket
module "website_bucket" {
  source = "../.."

  bucket_name       = "example-website-${random_id.suffix.hex}"
  environment       = "prod"
  enable_versioning = true

  # Must disable public access blocks for website hosting
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # Website configuration
  website_configuration = {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Project = "Marketing"
    Purpose = "StaticWebsite"
  }
}

# Logging bucket for access logs
resource "aws_s3_bucket" "logs" {
  bucket = "example-logs-bucket-${random_id.suffix.hex}"

  tags = {
    Application = "terraform-aws-s3-example"
    Environment = "prod"
    ManagedBy   = "terraform"
    Purpose     = "AccessLogs"
  }
}

# Required: Enable ACLs for logging bucket (S3 log delivery requires this)
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  depends_on = [aws_s3_bucket_ownership_controls.logs]
  bucket     = aws_s3_bucket.logs.id
  acl        = "log-delivery-write"
}

# Security: Block public access to logging bucket
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Security: Enable versioning on logging bucket
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Security: Enable SSE-S3 encryption on logging bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
