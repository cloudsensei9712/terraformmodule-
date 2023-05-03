output "ses_domain_arn" {
  description ="SES EMail domain arn"
  value       = aws_ses_domain_identity.ses_domain.arn
}

