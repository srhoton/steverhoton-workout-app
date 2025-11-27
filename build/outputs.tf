output "ecr_repository_url" {
  description = "URL of the ECR repository for pushing Docker images"
  value       = aws_ecr_repository.workout_app_build.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.workout_app_build.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.workout_app_build.name
}

output "ecr_registry_id" {
  description = "Registry ID where the repository was created"
  value       = aws_ecr_repository.workout_app_build.registry_id
}

# CodeBuild outputs
output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.workout_app_runner.name
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.workout_app_runner.arn
}

output "codebuild_service_role_arn" {
  description = "ARN of the CodeBuild service role"
  value       = aws_iam_role.codebuild_role.arn
}
