# -----------------------------------------------------------------------------
# KMS Key for S3 Bucket Encryption (Conditional)
# Created when kms_key_arn is not provided
# -----------------------------------------------------------------------------

# Data source for current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# KMS key policy document (Security Review Finding #1)
# Defines secure access for S3 service principal and account root
data "aws_iam_policy_document" "kms_key_policy" {
  count = local.create_kms_key ? 1 : 0

  # Allow root account full access for key administration
  statement {
    sid    = "EnableRootAccountPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow S3 service to use the key for encryption operations
  statement {
    sid    = "AllowS3ServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# KMS key resource
resource "aws_kms_key" "this" {
  count = local.create_kms_key ? 1 : 0

  description             = "KMS key for S3 bucket encryption: ${var.bucket_name}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy[0].json

  tags = local.tags
}

# KMS key alias for human-friendly reference
# Note: Alias names can only contain [0-9A-Za-z_/-], so dots are replaced with hyphens
resource "aws_kms_alias" "this" {
  count = local.create_kms_key ? 1 : 0

  name          = "alias/s3-${replace(var.bucket_name, ".", "-")}"
  target_key_id = aws_kms_key.this[0].key_id
}
