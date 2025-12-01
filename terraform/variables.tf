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

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "cloudfront_cache_policy_id" {
  description = "CloudFront managed cache policy ID (default: CachingOptimized)"
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "cloudfront_origin_request_policy_id" {
  description = "CloudFront managed origin request policy ID (default: CORS-S3Origin)"
  type        = string
  default     = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
}

variable "enable_spa_error_handling" {
  description = "Enable custom error responses for single-page application routing"
  type        = bool
  default     = true
}

variable "cloudfront_geo_restriction_type" {
  description = "Type of geographic restriction (none, whitelist, blacklist)"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cloudfront_geo_restriction_type)
    error_message = "Geo restriction type must be one of: none, whitelist, blacklist."
  }
}

variable "cloudfront_geo_restriction_locations" {
  description = "List of country codes for geographic restriction"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for loc in var.cloudfront_geo_restriction_locations : can(regex("^[A-Z]{2}$", loc))])
    error_message = "Location codes must be two-letter ISO 3166-1-alpha-2 country codes (e.g., US, GB, CA)."
  }
}
