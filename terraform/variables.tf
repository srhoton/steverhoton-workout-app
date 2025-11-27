variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "Must be a valid AWS region format (e.g., us-west-2)."
  }
}

variable "bucket_name" {
  description = "Name of the S3 bucket for hosting site code"
  type        = string
  default     = "steverhoton-workout-app"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase, and can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource tagging (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project name for resource tagging and identification"
  type        = string
  default     = "steverhoton-workout-app"
}

variable "owner" {
  description = "Owner of the infrastructure resources"
  type        = string
  default     = "srhoton"

  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must not be empty."
  }
}

variable "cost_center" {
  description = "Cost center for billing and cost allocation"
  type        = string
  default     = "engineering"

  validation {
    condition     = length(var.cost_center) > 0
    error_message = "Cost center must not be empty."
  }
}

variable "enable_versioning" {
  description = "Enable versioning for S3 bucket to protect against accidental deletion"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules to transition old versions to cheaper storage"
  type        = bool
  default     = true
}

variable "noncurrent_version_transition_days" {
  description = "Number of days after which noncurrent versions transition to STANDARD_IA"
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_transition_days >= 30
    error_message = "Transition to STANDARD_IA requires a minimum of 30 days."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent versions expire"
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "Expiration days must be at least 1."
  }
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects (use with caution)"
  type        = bool
  default     = false
}
