locals {
  # Common tags applied to all resources via default_tags in provider configuration
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }

  # Bucket naming with region suffix for clarity
  bucket_full_name = var.bucket_name
}
