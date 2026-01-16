# Outputs for basic example

output "bucket_id" {
  description = "The name of the bucket"
  value       = module.secure_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = module.secure_bucket.bucket_arn
}

output "bucket_domain_name" {
  description = "Bucket domain name"
  value       = module.secure_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional bucket domain name"
  value       = module.secure_bucket.bucket_regional_domain_name
}
