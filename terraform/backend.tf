terraform {
  backend "s3" {
    bucket = "srhoton-tfstate"
    key    = "steverhoton-workout-app/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
