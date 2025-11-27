.PHONY: help init plan apply destroy validate format lint clean docs

# Default target
help:
	@echo "Available targets:"
	@echo "  init       - Initialize OpenTofu/Terraform"
	@echo "  plan       - Generate and show execution plan"
	@echo "  apply      - Build or change infrastructure"
	@echo "  destroy    - Destroy infrastructure"
	@echo "  validate   - Validate configuration files"
	@echo "  format     - Format configuration files"
	@echo "  lint       - Run tflint"
	@echo "  docs       - Generate documentation"
	@echo "  clean      - Remove temporary files"

# Initialize OpenTofu/Terraform
init:
	tofu init

# Generate execution plan
plan:
	tofu plan

# Apply changes
apply:
	tofu apply

# Destroy infrastructure
destroy:
	tofu destroy

# Validate configuration
validate:
	tofu validate

# Format code
format:
	tofu fmt -recursive

# Run linting
lint:
	tflint --init
	tflint

# Generate documentation
docs:
	terraform-docs markdown table --output-file README.md --output-mode inject .

# Clean temporary files
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f tfplan
