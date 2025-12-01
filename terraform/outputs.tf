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

# CloudFront outputs
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site_distribution.arn
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site_distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID for alias records"
  value       = aws_cloudfront_distribution.site_distribution.hosted_zone_id
}

output "cloudfront_status" {
  description = "The current status of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site_distribution.status
}

output "cloudfront_oac_id" {
  description = "The ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.site_oac.id
}
