# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "bucket_name" {
  description = "Unique name for the S3 bucket. Must be globally unique across all AWS accounts."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, start and end with lowercase alphanumeric, and contain only lowercase letters, numbers, hyphens, and dots."
  }
}

variable "environment" {
  description = "Deployment environment identifier (e.g., dev, staging, prod). Used for tagging."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "development", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, development, production."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables - Encryption
# -----------------------------------------------------------------------------

variable "kms_key_arn" {
  description = "ARN of an existing KMS key for bucket encryption. If not provided, the module creates a new KMS key."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null ? true : can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]+:key/[a-f0-9-]+$", var.kms_key_arn))
    error_message = "kms_key_arn must be a valid KMS key ARN."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables - Versioning
# -----------------------------------------------------------------------------

variable "enable_versioning" {
  description = "Enable bucket versioning for object version management and data protection. WARNING: Once enabled, versioning can only be suspended, not disabled. Suspending versioning does not delete existing versions."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Optional Variables - Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources. Merged with default module tags (environment, managed_by, module)."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Optional Variables - Public Access Block
# -----------------------------------------------------------------------------

variable "block_public_acls" {
  description = "Block public ACL creation on the bucket. Set to false only for static website hosting."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policy attachment. Set to false only for static website hosting."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore existing public ACLs on the bucket. Set to false only for static website hosting."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies. Set to false only for static website hosting."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Optional Variables - Logging
# -----------------------------------------------------------------------------

variable "enable_logging" {
  description = "Enable server access logging. Requires logging_bucket to be specified when true."
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "Name of the target bucket for server access logs. Must exist and have appropriate permissions (log-delivery-write ACL)."
  type        = string
  default     = null

  validation {
    condition     = var.logging_bucket == null ? true : length(var.logging_bucket) > 0
    error_message = "logging_bucket must not be empty when provided."
  }
}

variable "logging_prefix" {
  description = "Prefix for log object keys in the logging bucket."
  type        = string
  default     = "logs/"
}

# -----------------------------------------------------------------------------
# Optional Variables - Lifecycle Rules
# -----------------------------------------------------------------------------

variable "lifecycle_rules" {
  description = "Lifecycle rules for object transitions and expiration. Supports storage class transitions, expiration, and noncurrent version management."
  type = list(object({
    id      = string
    enabled = optional(bool, true)
    prefix  = optional(string, "")
    tags    = optional(map(string), {})

    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])

    expiration = optional(object({
      days                         = optional(number)
      expired_object_delete_marker = optional(bool, false)
    }))

    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])

    noncurrent_version_expiration = optional(object({
      noncurrent_days           = number
      newer_noncurrent_versions = optional(number)
    }))

    abort_incomplete_multipart_upload_days = optional(number)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Optional Variables - Website Hosting
# -----------------------------------------------------------------------------

variable "website_configuration" {
  description = "Static website hosting configuration. Requires all public access blocks to be disabled (block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets must all be false)."
  type = object({
    index_document = string
    error_document = optional(string, "error.html")
  })
  default = null
}

# -----------------------------------------------------------------------------
# Optional Variables - KMS Key Configuration (Security Review Finding #8)
# -----------------------------------------------------------------------------

variable "kms_deletion_window_in_days" {
  description = "Waiting period in days before KMS key deletion. Only applies when module creates the KMS key. Minimum 7 days, maximum 30 days."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days must be between 7 and 30."
  }
}
