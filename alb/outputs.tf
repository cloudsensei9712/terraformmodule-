# Outputs

output "albDNS" {
  value       = aws_lb.age_alb.dns_name
  description = "DNS of the ALB created"
}

output "albArn" {
  value       = aws_lb.age_alb.arn
  description = "Arn of the ALB created"
}

output "albTargetGroupArn" {
  value       = aws_lb_target_group.age_target_group.arn
  description = "Arn of app server target group."
}