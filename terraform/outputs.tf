output "bucket_id" {
  description = "The name/id of the S3 bucket"
  value       = aws_s3_bucket.workout_app_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.workout_app_bucket.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name for accessing the bucket"
  value       = aws_s3_bucket.workout_app_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name for accessing the bucket"
  value       = aws_s3_bucket.workout_app_bucket.bucket_regional_domain_name
}

output "bucket_region" {
  description = "The AWS region where the bucket is created"
  value       = aws_s3_bucket.workout_app_bucket.region
}

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = var.enable_versioning
}

output "encryption_enabled" {
  description = "Whether server-side encryption is enabled on the bucket"
  value       = var.enable_encryption
}
