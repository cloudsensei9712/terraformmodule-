output "secret_arn" {
  description = "ARN of the secret."
  value       = join("", aws_secretsmanager_secret.secret[*].arn)
}
