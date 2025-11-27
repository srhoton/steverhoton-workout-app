terraform {
  backend "s3" {
    bucket = "srhoton-tfstate"
    key    = "steverhoton-workout-app/build/terraform.tfstate"
    region = "us-east-1"

    # Enable encryption at rest for state file
    encrypt = true
  }
}
