variable "aws_region" {
  description = "AWS region where the ECR repository will be created"
  type        = string
  default     = "us-west-2"
}

variable "repository_name" {
  description = "Name of the ECR repository for storing Docker images"
  type        = string
  default     = "steverhoton-workout-app/build"
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository. Set to MUTABLE for development, IMMUTABLE for production"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable automatic image scanning when images are pushed to the repository"
  type        = bool
  default     = true
}

variable "image_retention_count" {
  description = "Number of images to retain in the repository. Older images will be automatically deleted"
  type        = number
  default     = 30

  validation {
    condition     = var.image_retention_count > 0 && var.image_retention_count <= 1000
    error_message = "Image retention count must be between 1 and 1000."
  }
}

variable "environment" {
  description = "Environment name for tagging purposes"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging purposes"
  type        = string
  default     = "workout-app"
}

# CodeBuild variables
variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
  default     = "steverhoton-workout-app-runner"
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
  default     = "srhoton/steverhoton-workout-app"
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60

  validation {
    condition     = var.build_timeout >= 5 && var.build_timeout <= 480
    error_message = "Build timeout must be between 5 and 480 minutes."
  }
}

variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition = contains([
      "BUILD_GENERAL1_SMALL",
      "BUILD_GENERAL1_MEDIUM",
      "BUILD_GENERAL1_LARGE",
      "BUILD_GENERAL1_2XLARGE"
    ], var.compute_type)
    error_message = "Compute type must be a valid CodeBuild compute type."
  }
}

variable "privileged_mode" {
  description = "Enable privileged mode for Docker-in-Docker builds"
  type        = bool
  default     = false
}
