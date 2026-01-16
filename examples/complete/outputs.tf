# Outputs for complete example

# Data bucket outputs
output "data_bucket_id" {
  description = "The name of the data bucket"
  value       = module.data_bucket.bucket_id
}

output "data_bucket_arn" {
  description = "ARN of the data bucket"
  value       = module.data_bucket.bucket_arn
}

output "data_bucket_domain_name" {
  description = "Data bucket domain name"
  value       = module.data_bucket.bucket_domain_name
}

# Website bucket outputs
output "website_bucket_id" {
  description = "The name of the website bucket"
  value       = module.website_bucket.bucket_id
}

output "website_bucket_arn" {
  description = "ARN of the website bucket"
  value       = module.website_bucket.bucket_arn
}

output "website_endpoint" {
  description = "Website endpoint URL"
  value       = module.website_bucket.website_endpoint
}

output "website_domain" {
  description = "Website domain for DNS configuration"
  value       = module.website_bucket.website_domain
}

# Logging bucket output
output "logs_bucket_id" {
  description = "The name of the logging bucket"
  value       = aws_s3_bucket.logs.id
}
