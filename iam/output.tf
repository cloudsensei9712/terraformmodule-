output "app_instance_role_arn" {
  description = "App instance role ARN."
  value       = join("", aws_iam_role.app_instance_role.*.arn)
}
output "app_instance_profile_arn" {
  description = "App instance profile ARN."
  value       = join("", aws_iam_instance_profile.app_instance_profile.*.arn)
}
output "app_ecs_task_role_arn" {
  description = "App ECS task role ARN."
  value       = join("", aws_iam_role.app_ecs_task_role.*.arn)
}
# output "app_rds_role_arn" {
#   description = "App RDS role ARN."
#   value       = join("", aws_iam_role.app_rds_role.*.arn)
# }
output "app_rds_monitoring_role_arn" {
  description = "App RDS monitoring role ARN."
  value       = join("", aws_iam_role.app_rds_monitoring_role.*.arn)
}
