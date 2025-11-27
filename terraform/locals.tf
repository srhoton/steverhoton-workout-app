locals {
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "OpenTofu"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }

  # Bucket name for consistent reference
  bucket_name = var.bucket_name
}
