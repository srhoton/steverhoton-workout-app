# S3 Bucket for workout app
resource "aws_s3_bucket" "workout_app_bucket" {
  bucket        = local.bucket_full_name
  force_destroy = var.force_destroy

  tags = {
    Name        = local.bucket_full_name
    Description = "S3 bucket for steverhoton workout application"
  }
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "workout_app_bucket_versioning" {
  bucket = aws_s3_bucket.workout_app_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "workout_app_bucket_encryption" {
  bucket = aws_s3_bucket.workout_app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "workout_app_bucket_public_access_block" {
  bucket = aws_s3_bucket.workout_app_bucket.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Lifecycle rules for cost optimization (optional)
resource "aws_s3_bucket_lifecycle_configuration" "workout_app_bucket_lifecycle" {
  count = var.lifecycle_rules_enabled ? 1 : 0

  bucket = aws_s3_bucket.workout_app_bucket.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = var.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }

    dynamic "expiration" {
      for_each = var.expiration_days > 0 ? [1] : []

      content {
        days = var.expiration_days
      }
    }
  }

  rule {
    id     = "abort_incomplete_multipart_upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Enable logging for S3 bucket access (optional - commented out as it requires a separate logging bucket)
# resource "aws_s3_bucket_logging" "workout_app_bucket_logging" {
#   bucket = aws_s3_bucket.workout_app_bucket.id
#
#   target_bucket = aws_s3_bucket.log_bucket.id
#   target_prefix = "s3-access-logs/"
# }
