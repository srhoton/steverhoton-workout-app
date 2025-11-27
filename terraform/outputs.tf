output "bucket_id" {
  description = "The ID (name) of the S3 bucket"
  value       = aws_s3_bucket.site_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.site_bucket.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name for the S3 bucket"
  value       = aws_s3_bucket.site_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name for the S3 bucket"
  value       = aws_s3_bucket.site_bucket.bucket_regional_domain_name
}

output "bucket_region" {
  description = "The AWS region where the bucket is located"
  value       = aws_s3_bucket.site_bucket.region
}

output "versioning_enabled" {
  description = "Whether versioning is enabled on the S3 bucket"
  value       = var.enable_versioning
}

output "encryption_algorithm" {
  description = "The encryption algorithm used for the S3 bucket"
  value       = "AES256"
}
