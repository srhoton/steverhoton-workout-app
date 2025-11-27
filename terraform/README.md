# Terraform Configuration for steverhoton-workout-app S3 Bucket

This Terraform/OpenTofu configuration creates and manages an S3 bucket for the steverhoton-workout-app with security best practices enabled.

## Overview

This configuration provisions:
- S3 bucket with configurable name
- Versioning enabled by default
- Server-side encryption (AES-256) enabled
- Public access blocked on all levels
- Optional lifecycle rules for cost optimization
- Comprehensive tagging strategy

## Prerequisites

- Terraform >= 1.5.0 or OpenTofu >= 1.5.0
- AWS CLI configured with appropriate credentials
- S3 bucket `srhoton-tfstate` must exist in `us-east-1` region for state storage
- AWS credentials with permissions to create and manage S3 buckets

## Architecture

The configuration follows AWS and Terraform best practices:

### Security Features
- **Encryption at Rest**: AES-256 server-side encryption enabled by default
- **Public Access Block**: All public access blocked at bucket level
- **Versioning**: Enabled to maintain object history and enable recovery
- **State Encryption**: Remote state is encrypted in S3

### Resource Structure
```
S3 Bucket (steverhoton-workout-app)
├── Versioning Configuration
├── Server-Side Encryption
├── Public Access Block
└── Lifecycle Configuration (optional)
```

## Usage

### Initialize Terraform
```bash
cd terraform
terraform init
```

### Validate Configuration
```bash
terraform validate
```

### Plan Changes
```bash
terraform plan
```

### Apply Configuration
```bash
terraform apply
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Configuration

### Required Variables

All variables have sensible defaults but can be overridden:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| aws_region | AWS region for the bucket | us-west-2 | No |
| bucket_name | S3 bucket name | steverhoton-workout-app | No |
| environment | Environment tag | production | No |
| project_name | Project name tag | steverhoton-workout-app | No |
| owner | Owner tag | steverhoton | No |

### Optional Configuration

You can customize the configuration using a `terraform.tfvars` file:

```hcl
# terraform.tfvars
aws_region   = "us-west-2"
bucket_name  = "steverhoton-workout-app"
environment  = "production"
owner        = "steverhoton"
cost_center  = "engineering"

# Enable lifecycle rules for cost optimization
lifecycle_rules_enabled  = true
transition_to_ia_days    = 90
transition_to_glacier_days = 180
expiration_days          = 365
```

## State Management

This configuration uses remote state with the following backend:
- **Backend**: S3
- **State Bucket**: `srhoton-tfstate`
- **State Key**: `steverhoton-workout-app/terraform.tfstate`
- **Region**: `us-east-1`
- **Encryption**: Enabled

**Note**: DynamoDB state locking is intentionally not configured per project requirements.

## Security Considerations

1. **State File Security**: The remote state bucket should have:
   - Versioning enabled
   - Encryption enabled
   - Access restricted to authorized users only

2. **Least Privilege**: Ensure AWS credentials used have minimum required permissions

3. **No Hardcoded Secrets**: All sensitive values should be passed via variables or environment variables

## Outputs

The configuration provides the following outputs:

| Output | Description |
|--------|-------------|
| bucket_id | The name/id of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The regional bucket domain name |
| bucket_region | The AWS region of the bucket |

Access outputs after apply:
```bash
terraform output
terraform output bucket_arn
```

## File Structure

```
terraform/
├── backend.tf              # Remote state configuration
├── locals.tf               # Local values and computed variables
├── main.tf                 # Primary S3 bucket resources
├── outputs.tf              # Output value declarations
├── providers.tf            # AWS provider configuration
├── variables.tf            # Input variable declarations
├── versions.tf             # Terraform and provider version constraints
├── .tflint.hcl            # TFLint configuration
├── .terraform-docs.yml     # terraform-docs configuration
└── README.md              # This file
```

## Linting and Validation

### TFLint
```bash
tflint --init
tflint
```

### Terraform Format
```bash
terraform fmt -recursive
```

### Security Scanning
```bash
# Using checkov
checkov -d .

# Using tfsec
tfsec .
```

## Troubleshooting

### State Bucket Access
If you receive errors about the state bucket:
1. Ensure `srhoton-tfstate` bucket exists in `us-east-1`
2. Verify your AWS credentials have access to the bucket
3. Check the bucket has versioning and encryption enabled

### Bucket Name Conflicts
If the bucket name is already taken:
1. S3 bucket names must be globally unique
2. Override the `bucket_name` variable with a unique name

### Permission Errors
Ensure your AWS credentials have the following permissions:
- `s3:CreateBucket`
- `s3:DeleteBucket`
- `s3:PutBucketVersioning`
- `s3:PutEncryptionConfiguration`
- `s3:PutBucketPublicAccessBlock`
- `s3:PutLifecycleConfiguration`

## Maintenance

### Updating Terraform Version
Update the `required_version` in `versions.tf`:
```hcl
terraform {
  required_version = ">= 1.6.0"
}
```

### Updating AWS Provider
Update the provider version in `versions.tf`:
```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}
```

Then run:
```bash
terraform init -upgrade
```

## Contributing

When making changes to this configuration:
1. Run `terraform fmt` before committing
2. Run `terraform validate` to check syntax
3. Run `tflint` to check for issues
4. Update this README if adding new variables or outputs
5. Test changes in a non-production environment first

## License

This configuration is part of the steverhoton-workout-app project.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Terraform/AWS documentation
3. Contact the infrastructure team

---

**Managed By**: Terraform/OpenTofu
**Last Updated**: 2025-11-27
