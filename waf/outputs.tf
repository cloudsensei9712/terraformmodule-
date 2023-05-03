output "waf_arn" {
  description = "ARN of Web ACL"
  value       = aws_wafv2_web_acl.waf[*].arn 
}