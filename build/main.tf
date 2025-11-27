# AWS Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values for consistent tagging
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "opentofu"
  }
}

# ECR repository for storing Docker images
resource "aws_ecr_repository" "workout_app_build" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Enable image scanning on push for security
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Encryption configuration for images at rest
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = var.repository_name
  }
}

# Lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "workout_app_build_policy" {
  repository = aws_ecr_repository.workout_app_build.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.image_retention_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR repository policy to restrict access to same account only
resource "aws_ecr_repository_policy" "workout_app_build_policy" {
  repository = aws_ecr_repository.workout_app_build.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      },
      {
        Sid    = "AllowCodeBuildPull"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Get current AWS account ID for IAM policies
data "aws_caller_identity" "current" {}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.codebuild_project_name}-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.codebuild_project_name}-service-role"
  }
}

# IAM policy for CodeBuild permissions
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.codebuild_project_name}-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudWatch Logs permissions
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.codebuild_project_name}",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.codebuild_project_name}:*"
        ]
      },
      {
        # ECR permissions for pulling the build image
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        # ECR permissions for the build image repository
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = aws_ecr_repository.workout_app_build.arn
      },
      {
        # CodeBuild report group permissions
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:report-group/${var.codebuild_project_name}-*"
      }
    ]
  })
}

# CodeBuild project for GitHub Actions runner
resource "aws_codebuild_project" "workout_app_runner" {
  name          = var.codebuild_project_name
  description   = "CodeBuild runner project for ${var.github_repo}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = var.compute_type
    image                       = "${aws_ecr_repository.workout_app_build.repository_url}:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = var.privileged_mode
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.codebuild_project_name}"
      stream_name = "build-log"
    }
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/${var.github_repo}.git"
  }

  tags = {
    Name = var.codebuild_project_name
  }
}
