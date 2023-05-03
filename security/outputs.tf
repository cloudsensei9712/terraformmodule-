output "albSecurityGroupId" {
  value = aws_security_group.age_alb_sg.id
}
output "ecsSecurityGroupId" {
  value = aws_security_group.age_ecs_sg.id
}
output "dbSecurityGroupId" {
  value = aws_security_group.age_db_sg.id
}