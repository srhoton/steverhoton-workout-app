variable "aws_region" {
  description = "AWS region where the S3 bucket will be created"
  type        = string
  default     = "us-west-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "Must be a valid AWS region format (e.g., us-west-2)."
  }
}

variable "bucket_name" {
  description = "Name of the S3 bucket for the workout app. Must be globally unique and follow AWS naming conventions."
  type        = string
  default     = "steverhoton-workout-app"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3-63 characters, start and end with lowercase letter or number, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource tagging (e.g., dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "development", "staging", "production", "prod"], var.environment)
    error_message = "Environment must be one of: dev, development, staging, production, prod."
  }
}

variable "project_name" {
  description = "Name of the project for resource tagging and identification"
  type        = string
  default     = "steverhoton-workout-app"
}

variable "owner" {
  description = "Owner or team responsible for the infrastructure"
  type        = string
  default     = "steverhoton"
}

variable "cost_center" {
  description = "Cost center or department for billing and cost allocation"
  type        = string
  default     = "engineering"
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket to maintain object version history"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption for the S3 bucket using AES-256"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Enable all S3 bucket public access block settings for security"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow destruction of bucket even if it contains objects (use with caution)"
  type        = bool
  default     = false
}

variable "lifecycle_rules_enabled" {
  description = "Enable lifecycle rules for transitioning objects to cheaper storage classes"
  type        = bool
  default     = false
}

variable "transition_to_ia_days" {
  description = "Number of days after which objects transition to Infrequent Access storage class"
  type        = number
  default     = 90

  validation {
    condition     = var.transition_to_ia_days >= 30
    error_message = "Transition to IA must be at least 30 days."
  }
}

variable "transition_to_glacier_days" {
  description = "Number of days after which objects transition to Glacier storage class"
  type        = number
  default     = 180

  validation {
    condition     = var.transition_to_glacier_days >= 90
    error_message = "Transition to Glacier must be at least 90 days."
  }
}

variable "expiration_days" {
  description = "Number of days after which objects expire and are deleted. Set to 0 to disable expiration."
  type        = number
  default     = 0

  validation {
    condition     = var.expiration_days >= 0
    error_message = "Expiration days must be 0 or greater."
  }
}
