# S3 Bucket Infrastructure for Workout App

This OpenTofu/Terraform configuration creates and manages an S3 bucket for hosting the Workout App site code with industry-standard security best practices.

## Overview

This infrastructure as code (IaC) project provisions a secure S3 bucket in AWS with the following features:

- **Encryption**: Server-side encryption (AES256) enabled by default
- **Versioning**: Object versioning enabled to protect against accidental deletion
- **Public Access**: All public access blocked for security
- **Lifecycle Management**: Automatic transition of old versions to cheaper storage and expiration
- **Ownership Controls**: Bucket owner enforced for consistent permissions

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

- **aws_s3_bucket**: Main S3 bucket for hosting site code
- **aws_s3_bucket_versioning**: Versioning configuration
- **aws_s3_bucket_server_side_encryption_configuration**: Encryption settings
- **aws_s3_bucket_public_access_block**: Public access blocking
- **aws_s3_bucket_lifecycle_configuration**: Lifecycle rules for cost optimization
- **aws_s3_bucket_ownership_controls**: Ownership enforcement

### Security Features

1. **Encryption at Rest**: All objects are encrypted using AES256
2. **Public Access Blocking**: Four-layer protection against public exposure:
   - Block public ACLs
   - Block public bucket policies
   - Ignore public ACLs
   - Restrict public buckets
3. **Versioning**: Enabled to protect against accidental deletion or modification
4. **Bucket Key**: Enabled to reduce encryption costs

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

| Output | Description |
|--------|-------------|
| `bucket_id` | The ID (name) of the S3 bucket |
| `bucket_arn` | The ARN of the S3 bucket |
| `bucket_domain_name` | The bucket domain name |
| `bucket_regional_domain_name` | The regional bucket domain name |
| `bucket_region` | The AWS region of the bucket |
| `versioning_enabled` | Whether versioning is enabled |
| `encryption_algorithm` | The encryption algorithm used |

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
- `s3:CreateBucket`
- `s3:PutBucketVersioning`
- `s3:PutEncryptionConfiguration`
- `s3:PutBucketPublicAccessBlock`
- `s3:PutLifecycleConfiguration`
- `s3:PutBucketOwnershipControls`

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
