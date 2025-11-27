# Quick Start Guide

This guide will help you quickly deploy the S3 bucket infrastructure using Terraform/OpenTofu.

## Prerequisites

1. Install Terraform or OpenTofu:
   ```bash
   # For Terraform
   brew install terraform

   # For OpenTofu
   brew install opentofu
   ```

2. Configure AWS credentials:
   ```bash
   aws configure
   ```

3. Ensure the state bucket exists:
   ```bash
   aws s3 ls s3://srhoton-tfstate --region us-east-1
   ```

## Quick Deployment

### Step 1: Initialize Terraform

```bash
cd terraform
terraform init
```

Expected output:
```
Initializing the backend...
Successfully configured the backend "s3"!
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 2: Review the Plan

```bash
terraform plan
```

This will show you what resources will be created without making any changes.

### Step 3: Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 4: Verify Outputs

```bash
terraform output
```

Example output:
```
bucket_arn                  = "arn:aws:s3:::steverhoton-workout-app"
bucket_id                   = "steverhoton-workout-app"
bucket_domain_name          = "steverhoton-workout-app.s3.amazonaws.com"
bucket_regional_domain_name = "steverhoton-workout-app.s3.us-west-2.amazonaws.com"
bucket_region               = "us-west-2"
```

## Customization (Optional)

If you want to customize the configuration:

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your preferred values:
   ```bash
   nano terraform.tfvars
   ```

3. Re-run plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Common Commands

### View Current State
```bash
terraform show
```

### List Resources
```bash
terraform state list
```

### Get Specific Output
```bash
terraform output bucket_arn
```

### Refresh State
```bash
terraform refresh
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Validation and Linting

### Format Code
```bash
terraform fmt -recursive
```

### Validate Configuration
```bash
terraform validate
```

### Run TFLint
```bash
tflint --init
tflint
```

### Security Scan with Checkov
```bash
checkov -d .
```

## Troubleshooting

### Issue: Backend bucket not found
**Error**: `Error: Failed to get existing workspaces: S3 bucket does not exist`

**Solution**: Create the state bucket first:
```bash
aws s3 mb s3://srhoton-tfstate --region us-east-1
aws s3api put-bucket-versioning --bucket srhoton-tfstate --versioning-configuration Status=Enabled --region us-east-1
```

### Issue: Bucket name already exists
**Error**: `BucketAlreadyExists: The requested bucket name is not available`

**Solution**: S3 bucket names must be globally unique. Change the bucket name in `terraform.tfvars`:
```hcl
bucket_name = "steverhoton-workout-app-unique-suffix"
```

### Issue: Permission denied
**Error**: `AccessDenied: Access Denied`

**Solution**: Ensure your AWS credentials have the required permissions. You can verify with:
```bash
aws sts get-caller-identity
aws s3 ls  # Test S3 access
```

## Next Steps

After successful deployment:

1. Verify the bucket in AWS Console
2. Configure application to use the bucket
3. Set up bucket policies if needed for application access
4. Configure CloudWatch alarms for monitoring (optional)
5. Set up S3 event notifications if needed (optional)

## Support

For more detailed information, see the main [README.md](README.md).

---

**Last Updated**: 2025-11-27
