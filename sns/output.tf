output "sns_topic_arn" {
  description = "SNS Topic Arn"
  value       = aws_sns_topic.sns_topic.arn
}

