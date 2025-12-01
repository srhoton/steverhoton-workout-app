# CloudFront Origin Access Control (OAC) for S3 bucket access
resource "aws_cloudfront_origin_access_control" "site_oac" {
  name                              = "${local.bucket_name}-oac"
  description                       = "Origin Access Control for ${local.bucket_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution for the workout app
resource "aws_cloudfront_distribution" "site_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.project_name}"
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  # S3 origin configuration
  origin {
    domain_name              = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id                = "S3-${local.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site_oac.id
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${local.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # Use managed cache policy for optimized caching
    cache_policy_id = var.cloudfront_cache_policy_id

    # Use managed origin request policy
    origin_request_policy_id = var.cloudfront_origin_request_policy_id
  }

  # Custom error responses for single-page applications
  dynamic "custom_error_response" {
    for_each = var.enable_spa_error_handling ? [1] : []
    content {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  }

  dynamic "custom_error_response" {
    for_each = var.enable_spa_error_handling ? [1] : []
    content {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  }

  # Viewer certificate configuration
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restriction_locations
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.project_name}-distribution"
      Description = "CloudFront distribution for workout app static content"
    }
  )
}

# S3 bucket policy to allow CloudFront OAC to access the bucket
resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site_distribution.arn
          }
        }
      }
    ]
  })

  # Ensure public access block is configured before applying policy
  depends_on = [
    aws_s3_bucket_public_access_block.site_bucket_public_access_block
  ]
}
