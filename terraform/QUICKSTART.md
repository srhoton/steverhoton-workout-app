# Quick Start Guide

This guide will help you quickly deploy the S3 bucket infrastructure using OpenTofu.

## Prerequisites

1. Install OpenTofu (or Terraform):
   ```bash
   # macOS
   brew install opentofu

   # Or install Terraform
   brew install terraform
   ```

2. Configure AWS credentials:
   ```bash
   aws configure
   ```

3. Verify access to the remote state bucket:
   ```bash
   aws s3 ls s3://srhoton-tfstate/
   ```

## Deployment Steps

### Step 1: Navigate to the terraform directory

```bash
cd terraform
```

### Step 2: Initialize OpenTofu

```bash
tofu init
```

This will:
- Download the AWS provider
- Configure the remote state backend
- Prepare your workspace

### Step 3: Review the plan

```bash
tofu plan
```

This shows you exactly what will be created. You should see:
- 1 S3 bucket
- 1 versioning configuration
- 1 encryption configuration
- 1 public access block
- 1 lifecycle configuration
- 1 ownership controls configuration

### Step 4: Apply the configuration

```bash
tofu apply
```

Type `yes` when prompted to confirm.

### Step 5: Verify the deployment

```bash
# View outputs
tofu output

# Verify the bucket exists
aws s3 ls s3://steverhoton-workout-app/
```

## Using the Makefile

For convenience, you can use the included Makefile:

```bash
# Initialize
make init

# Plan changes
make plan

# Apply changes
make apply

# Format code
make format

# Validate configuration
make validate

# Run linting
make lint
```

## Customization

If you need to customize the configuration:

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your preferences:
   ```hcl
   environment = "dev"
   owner       = "your-name"
   ```

3. Apply with your custom variables:
   ```bash
   tofu apply
   ```

## Common Tasks

### Uploading files to the bucket

```bash
# Upload a single file
aws s3 cp myfile.txt s3://steverhoton-workout-app/

# Sync a directory
aws s3 sync ./build s3://steverhoton-workout-app/
```

### Viewing bucket contents

```bash
aws s3 ls s3://steverhoton-workout-app/
```

### Downloading files

```bash
aws s3 cp s3://steverhoton-workout-app/myfile.txt ./
```

### Viewing object versions

```bash
aws s3api list-object-versions --bucket steverhoton-workout-app
```

## Cleanup

To destroy all resources:

```bash
tofu destroy
```

Or using the Makefile:

```bash
make destroy
```

**Warning**: This will delete the S3 bucket and all its contents if `force_destroy = true`.

## Troubleshooting

### Error: bucket already exists

If the bucket name is already taken globally, you need to change it:

```bash
tofu apply -var="bucket_name=your-unique-name"
```

### Error: access denied to state bucket

Ensure your AWS credentials have access to `s3://srhoton-tfstate/`:

```bash
aws s3 ls s3://srhoton-tfstate/
```

### Error: provider not found

Run the init command again:

```bash
tofu init -upgrade
```

## Next Steps

- Review the full [README.md](README.md) for detailed documentation
- Configure bucket policies if needed
- Set up CloudFront distribution for CDN (future enhancement)
- Configure Route53 DNS (future enhancement)

## Support

For issues or questions, contact the infrastructure team or open an issue in the repository.
