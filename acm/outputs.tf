output "aws_acm_certificate_arn" {
  description = "ARN of ACM certificate"
  value       = aws_acm_certificate.certficate.arn
}
