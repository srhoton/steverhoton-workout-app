.PHONY: help init plan apply destroy validate fmt lint security clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform working directory"
	@echo "  plan      - Generate and show execution plan"
	@echo "  apply     - Build or change infrastructure"
	@echo "  destroy   - Destroy Terraform-managed infrastructure"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  fmt       - Format Terraform files"
	@echo "  lint      - Run tflint on configuration"
	@echo "  security  - Run security scanning with checkov"
	@echo "  clean     - Remove Terraform artifacts"
	@echo "  docs      - Generate documentation with terraform-docs"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Generate execution plan
plan:
	@echo "Generating execution plan..."
	terraform plan

# Apply changes
apply:
	@echo "Applying Terraform configuration..."
	terraform apply

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure..."
	terraform destroy

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Run tflint
lint:
	@echo "Running tflint..."
	tflint --init
	tflint

# Run security scanning
security:
	@echo "Running security scan with checkov..."
	checkov -d .

# Clean Terraform artifacts
clean:
	@echo "Cleaning Terraform artifacts..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate.backup
	@echo "Note: terraform.tfstate is stored remotely and not deleted"

# Generate documentation
docs:
	@echo "Generating documentation..."
	terraform-docs markdown table --output-file README.md --output-mode inject .

# Full check (format, validate, lint, security)
check: fmt validate lint security
	@echo "All checks completed!"

# Quick deployment workflow
deploy: init plan apply
	@echo "Deployment complete!"
