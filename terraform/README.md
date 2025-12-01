# S3 Bucket and CloudFront Infrastructure for Workout App

This OpenTofu/Terraform configuration creates and manages an S3 bucket and CloudFront distribution for hosting the Workout App with industry-standard security best practices.

## Overview

This infrastructure as code (IaC) project provisions a secure S3 bucket and CloudFront CDN in AWS with the following features:

### S3 Bucket Features
- **Encryption**: Server-side encryption (AES256) enabled by default
- **Versioning**: Object versioning enabled to protect against accidental deletion
- **Public Access**: All public access blocked for security
- **Lifecycle Management**: Automatic transition of old versions to cheaper storage and expiration
- **Ownership Controls**: Bucket owner enforced for consistent permissions

### CloudFront Features
- **Origin Access Control (OAC)**: Modern, secure access to S3 bucket (replaces deprecated OAI)
- **HTTPS Enforcement**: All HTTP requests redirected to HTTPS
- **IPv6 Support**: Full IPv6 compatibility enabled
- **Caching**: Optimized caching with AWS managed cache policies
- **Compression**: Automatic compression for faster delivery
- **SPA Support**: Custom error handling for single-page applications
- **Cost Optimization**: PriceClass_100 for North America and Europe edge locations

## Prerequisites

Before using this configuration, ensure you have:

1. **OpenTofu or Terraform** installed (version >= 1.5.0)
2. **AWS CLI** configured with appropriate credentials
3. **Access to the remote state bucket**: `srhoton-tfstate` in `us-east-1`
4. **Appropriate AWS IAM permissions** to create and manage S3 resources

## Quick Start

### Initialize the Configuration

```bash
cd terraform
tofu init
```

or if using Terraform:

```bash
terraform init
```

### Review the Plan

```bash
tofu plan
```

### Apply the Configuration

```bash
tofu apply
```

### Destroy Resources (if needed)

```bash
tofu destroy
```

## Architecture

### Resources Created

#### S3 Resources
- **aws_s3_bucket**: Main S3 bucket for hosting site code
- **aws_s3_bucket_versioning**: Versioning configuration
- **aws_s3_bucket_server_side_encryption_configuration**: Encryption settings
- **aws_s3_bucket_public_access_block**: Public access blocking
- **aws_s3_bucket_lifecycle_configuration**: Lifecycle rules for cost optimization
- **aws_s3_bucket_ownership_controls**: Ownership enforcement
- **aws_s3_bucket_policy**: Bucket policy allowing CloudFront OAC access

#### CloudFront Resources
- **aws_cloudfront_origin_access_control**: Origin Access Control for secure S3 access
- **aws_cloudfront_distribution**: CDN distribution for content delivery

### Security Features

#### S3 Security
1. **Encryption at Rest**: All objects are encrypted using AES256
2. **Public Access Blocking**: Four-layer protection against public exposure:
   - Block public ACLs
   - Block public bucket policies
   - Ignore public ACLs
   - Restrict public buckets
3. **Versioning**: Enabled to protect against accidental deletion or modification
4. **Bucket Key**: Enabled to reduce encryption costs

#### CloudFront Security
1. **Origin Access Control (OAC)**: Uses AWS SigV4 signing for secure S3 access
2. **HTTPS Enforcement**: Viewer protocol policy set to redirect-to-https
3. **TLS 1.2 Minimum**: Uses TLSv1.2_2021 as minimum protocol version
4. **IAM-based Access**: Bucket policy restricts access to specific CloudFront distribution
5. **No Direct S3 Access**: S3 bucket remains private, accessible only via CloudFront

### Cost Optimization

The lifecycle configuration includes:

- **Transition Rule**: Noncurrent versions move to STANDARD_IA after 30 days
- **Expiration Rule**: Noncurrent versions are deleted after 90 days
- **Multipart Upload Cleanup**: Incomplete uploads are removed after 7 days

## Configuration

### Required Variables

None - all variables have sensible defaults.

### Optional Variables

| Variable | Description | Default | Validation |
|----------|-------------|---------|------------|
| `aws_region` | AWS region for resources | `us-west-2` | Valid AWS region format |
| `bucket_name` | S3 bucket name | `steverhoton-workout-app` | 3-63 chars, lowercase, alphanumeric + hyphens |
| `environment` | Environment name | `prod` | One of: dev, staging, prod |
| `project_name` | Project name | `steverhoton-workout-app` | - |
| `owner` | Owner of resources | `srhoton` | Non-empty string |
| `cost_center` | Cost center | `engineering` | Non-empty string |
| `enable_versioning` | Enable bucket versioning | `true` | Boolean |
| `enable_lifecycle_rules` | Enable lifecycle rules | `true` | Boolean |
| `noncurrent_version_transition_days` | Days until transition to STANDARD_IA | `30` | >= 30 |
| `noncurrent_version_expiration_days` | Days until version expiration | `90` | >= 1 |
| `force_destroy` | Allow bucket destruction with objects | `false` | Boolean |
| `cloudfront_price_class` | CloudFront distribution price class | `PriceClass_100` | PriceClass_All, PriceClass_200, PriceClass_100 |
| `cloudfront_cache_policy_id` | CloudFront managed cache policy ID | `658327ea-f89d-4fab-a63d-7e88639e58f6` | Valid policy ID |
| `cloudfront_origin_request_policy_id` | CloudFront origin request policy ID | `88a5eaf4-2fd4-4709-b370-b4c650ea3fcf` | Valid policy ID |
| `enable_spa_error_handling` | Enable SPA custom error responses | `true` | Boolean |
| `cloudfront_geo_restriction_type` | Geographic restriction type | `none` | none, whitelist, blacklist |
| `cloudfront_geo_restriction_locations` | Country codes for geo restriction | `[]` | ISO 3166-1-alpha-2 codes |

### Example Custom Configuration

Create a `terraform.tfvars` file:

```hcl
aws_region   = "us-west-2"
environment  = "prod"
owner        = "srhoton"
cost_center  = "engineering"

# Disable lifecycle rules if not needed
enable_lifecycle_rules = false

# Adjust lifecycle timings
noncurrent_version_transition_days = 60
noncurrent_version_expiration_days = 180
```

## Outputs

### S3 Outputs
| Output | Description |
|--------|-------------|
| `bucket_id` | The ID (name) of the S3 bucket |
| `bucket_arn` | The ARN of the S3 bucket |
| `bucket_domain_name` | The bucket domain name |
| `bucket_regional_domain_name` | The regional bucket domain name |
| `bucket_region` | The AWS region of the bucket |
| `versioning_enabled` | Whether versioning is enabled |
| `encryption_algorithm` | The encryption algorithm used |

### CloudFront Outputs
| Output | Description |
|--------|-------------|
| `cloudfront_distribution_id` | The ID of the CloudFront distribution |
| `cloudfront_distribution_arn` | The ARN of the CloudFront distribution |
| `cloudfront_domain_name` | The domain name for accessing content via CloudFront |
| `cloudfront_hosted_zone_id` | The Route 53 zone ID for alias records |
| `cloudfront_status` | Current deployment status of the distribution |
| `cloudfront_oac_id` | The ID of the Origin Access Control |

## Usage

### Accessing Your Content

After applying the configuration, your content will be accessible via CloudFront:

1. Get the CloudFront domain name:
```bash
tofu output cloudfront_domain_name
```

2. Access your site at: `https://<cloudfront-domain-name>/`

3. Upload files to S3 (they will be served through CloudFront):
```bash
aws s3 cp index.html s3://$(tofu output -raw bucket_id)/
```

### Invalidating CloudFront Cache

When you update content in S3, you may need to invalidate the CloudFront cache:

```bash
# Invalidate all files
aws cloudfront create-invalidation \
  --distribution-id $(tofu output -raw cloudfront_distribution_id) \
  --paths "/*"

# Invalidate specific files
aws cloudfront create-invalidation \
  --distribution-id $(tofu output -raw cloudfront_distribution_id) \
  --paths "/index.html" "/styles.css"
```

### Price Class Information

The default `PriceClass_100` includes edge locations in:
- United States
- Canada
- Europe
- Israel

To use all edge locations worldwide, set:
```hcl
cloudfront_price_class = "PriceClass_All"
```

## State Management

This configuration uses **remote state** stored in S3:

- **Bucket**: `srhoton-tfstate`
- **Key**: `steverhoton-workout-app/terraform.tfstate`
- **Region**: `us-east-1`
- **Encryption**: Enabled

**Note**: DynamoDB locking is not configured for this project.

## Tagging Strategy

All resources are automatically tagged with:

- **Environment**: Environment name (e.g., prod)
- **Project**: Project name (steverhoton-workout-app)
- **ManagedBy**: OpenTofu
- **Owner**: Resource owner (srhoton)
- **CostCenter**: Cost center (engineering)

Tags are applied automatically via the AWS provider's `default_tags` feature.

## Development Workflow

### Format Code

```bash
tofu fmt
```

### Validate Configuration

```bash
tofu validate
```

### Run Linting

```bash
tflint
```

### Security Scanning

```bash
# Using checkov
checkov -d .

# Using tfsec
tfsec .
```

### Generate Documentation

```bash
terraform-docs markdown table --output-file README.md --output-mode inject .
```

## Best Practices Implemented

- Snake_case naming convention for all resources
- Comprehensive variable validation
- Descriptive documentation for all variables and outputs
- Provider version pinning
- Remote state with encryption
- Security-first configuration (encryption, public access blocking)
- Cost optimization via lifecycle rules
- Consistent tagging strategy
- Separation of concerns (separate files for variables, outputs, providers, etc.)

## Troubleshooting

### State Bucket Access

If you encounter issues accessing the remote state bucket:

```bash
aws s3 ls s3://srhoton-tfstate/
```

Ensure your AWS credentials have appropriate permissions.

### Bucket Name Conflicts

S3 bucket names must be globally unique. If the default bucket name is taken, override it:

```bash
tofu apply -var="bucket_name=your-unique-bucket-name"
```

### Permission Issues

Ensure your AWS credentials have the following permissions:

#### S3 Permissions
- `s3:CreateBucket`
- `s3:PutBucketVersioning`
- `s3:PutEncryptionConfiguration`
- `s3:PutBucketPublicAccessBlock`
- `s3:PutLifecycleConfiguration`
- `s3:PutBucketOwnershipControls`
- `s3:PutBucketPolicy`

#### CloudFront Permissions
- `cloudfront:CreateDistribution`
- `cloudfront:GetDistribution`
- `cloudfront:UpdateDistribution`
- `cloudfront:DeleteDistribution`
- `cloudfront:CreateOriginAccessControl`
- `cloudfront:GetOriginAccessControl`
- `cloudfront:DeleteOriginAccessControl`

## Maintenance

### Updating Provider Versions

1. Update the version constraint in `versions.tf`
2. Run `tofu init -upgrade`
3. Review the changelog for breaking changes
4. Test in a non-production environment first

### Modifying Lifecycle Rules

To adjust when objects transition or expire, modify the variables:

```hcl
noncurrent_version_transition_days = 60  # Default: 30
noncurrent_version_expiration_days = 180 # Default: 90
```

## Contributing

When making changes to this infrastructure:

1. Create a feature branch
2. Run `tofu fmt` to format code
3. Run `tofu validate` to validate syntax
4. Run `tflint` to check for issues
5. Run `tofu plan` to review changes
6. Submit a pull request with a clear description

## License

This infrastructure code is managed by the steverhoton-workout-app project.

## Support

For questions or issues, contact the infrastructure team or create an issue in the project repository.

---

**Generated with OpenTofu** - Infrastructure as Code for the Workout App
