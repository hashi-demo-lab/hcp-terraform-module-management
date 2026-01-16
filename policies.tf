# -----------------------------------------------------------------------------
# Bucket Policy - HTTPS Only with Encryption Enforcement
# Security Review Findings #2 and #5
# -----------------------------------------------------------------------------

# Combined bucket policy document
data "aws_iam_policy_document" "bucket_policy" {
  # Statement 1: Deny non-HTTPS requests (Security Review Finding #2)
  # Scoped to specific data plane operations rather than s3:*
  statement {
    sid    = "DenyNonHTTPS"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectAcl",
      "s3:GetObjectVersionAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Statement 2: Deny uploads without encryption header (Security Review Finding #5)
  statement {
    sid    = "DenyUnencryptedUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  # Statement 3: Deny uploads missing encryption header (Security Review Finding #5)
  statement {
    sid    = "DenyMissingEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }
}

# Bucket policy resource
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  # Ensure public access block is configured first
  depends_on = [aws_s3_bucket_public_access_block.this]
}
