output "albSecurityGroupId" {
  value = aws_security_group.alb_sg.id
}
output "ecsSecurityGroupId" {
  value = aws_security_group.ecs_sg.id
}
output "dbSecurityGroupId" {
  value = aws_security_group.db_sg.id
}