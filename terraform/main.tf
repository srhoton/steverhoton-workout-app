# S3 Bucket for hosting site code
resource "aws_s3_bucket" "site_bucket" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    local.common_tags,
    {
      Name        = local.bucket_name
      Description = "S3 bucket for hosting workout app site code"
    }
  )
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "site_bucket_versioning" {
  bucket = aws_s3_bucket.site_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "site_bucket_encryption" {
  bucket = aws_s3_bucket.site_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "site_bucket_public_access_block" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle configuration for managing object versions
resource "aws_s3_bucket_lifecycle_configuration" "site_bucket_lifecycle" {
  count = var.enable_lifecycle_rules ? 1 : 0

  bucket = aws_s3_bucket.site_bucket.id

  rule {
    id     = "transition_noncurrent_versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_version_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  rule {
    id     = "cleanup_incomplete_multipart_uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Enable bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "site_bucket_ownership" {
  bucket = aws_s3_bucket.site_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Enable bucket logging (optional - uncomment and configure if needed)
# resource "aws_s3_bucket_logging" "site_bucket_logging" {
#   bucket = aws_s3_bucket.site_bucket.id
#
#   target_bucket = aws_s3_bucket.log_bucket.id
#   target_prefix = "s3-access-logs/"
# }
