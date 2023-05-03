output "registry_id" {
  value       = aws_ecr_repository.repo.registry_id
  description = "Registry ID."
}

output "registry_url" {
  value       = aws_ecr_repository.repo.repository_url
  description = "Repository URL."
}

output "repository_name" {
  value       = aws_ecr_repository.repo.name
  description = "Repository name."
}

output "arn" {
  value       = aws_ecr_repository.repo.arn
  description = "Repository ARN."
}
