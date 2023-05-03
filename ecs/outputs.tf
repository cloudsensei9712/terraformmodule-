output "ecrRepositoryUri" {
  value = aws_ecr_repository.age_ecr.repository_url
}

output "ecsClusterName" {
  value = "${var.project}-${var.environment}-cluster"
}

output "ecsServiceName" {
  value = aws_ecs_service.age_service.name
}