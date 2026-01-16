# -----------------------------------------------------------------------------
# Bucket Outputs
# -----------------------------------------------------------------------------

output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Bucket domain name (bucket.s3.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional bucket domain name (bucket.s3.region.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

# -----------------------------------------------------------------------------
# KMS Key Outputs (Sensitive)
# -----------------------------------------------------------------------------

output "kms_key_arn" {
  description = "ARN of the KMS key used for bucket encryption"
  value       = local.kms_key_arn
  sensitive   = true
}

output "kms_key_id" {
  description = "ID of the KMS key used for bucket encryption"
  value       = local.kms_key_id
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Website Outputs (Conditional)
# Only populated when website_configuration is provided
# -----------------------------------------------------------------------------

output "website_endpoint" {
  description = "Website endpoint URL (only when website hosting is enabled)"
  value       = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}

output "website_domain" {
  description = "Website domain for DNS configuration (only when website hosting is enabled)"
  value       = try(aws_s3_bucket_website_configuration.this[0].website_domain, null)
}
