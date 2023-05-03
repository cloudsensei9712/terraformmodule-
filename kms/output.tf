output "kms_key_id" {
  description = "KMS key id."
  value       = join("", aws_kms_key.kms_key.*.key_id)
}
output "kms_alias_arn" {
  description = "KMS alias ARN."
  value       = join("", aws_kms_alias.kms_alias.*.arn)
}
output "kms_key_arn" {
  description = "KMS key ARN."
  value       = join("", aws_kms_alias.kms_alias.*.target_key_arn)
}
