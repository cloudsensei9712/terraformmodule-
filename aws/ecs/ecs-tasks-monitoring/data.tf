data "aws_sns_topic" "t" {
  name = "${var.environment}-ecs-cloudwatch-alarms"
}

data "aws_iam_role" "existing_ecs_iam_role" {
  name = "${var.environment}-ecs-task-monitoring"
}