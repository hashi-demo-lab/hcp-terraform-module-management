# Basic example: Secure S3 bucket with default settings
# This example demonstrates the minimal configuration required to create
# a secure S3 bucket with KMS encryption, versioning, and public access blocking.

module "secure_bucket" {
  source = "../.."

  bucket_name = "example-secure-bucket-${random_id.suffix.hex}"
  environment = "dev"
}

resource "random_id" "suffix" {
  byte_length = 4
}
