terraform {
  backend "s3" {
    bucket = "srhoton-tfstate"
    key    = "steverhoton-workout-app/terraform.tfstate"
    region = "us-east-1"

    # Encryption for state file
    encrypt = true

    # Note: DynamoDB locking is intentionally not configured per requirements
  }
}
