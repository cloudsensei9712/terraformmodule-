resource "aws_ecr_repository" "age_ecr" {
  name                 = "${var.project}-${var.environment}-server"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "age_cluster" {
  name = "${var.project}-${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${var.project}-${var.environment}-cluster"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_ecs_task_definition" "age_task_defintion" {
  family                   = "${var.project}-${var.environment}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecsCpu
  memory                   = var.ecsMemory
  execution_role_arn       = var.ecsTaskExecutionRoleArn

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.project}-${var.environment}-task-definition",
      "image": "${var.ecsDefaultDockerImage}",
      "essential": true,
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": ${var.ecsContainerPort},
          "hostPort": ${var.ecsContainerPort}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/fargate/service/${var.project}-${var.environment}",
          "awslogs-region": "${var.ecsRegion}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION


  tags = {
    Name = "${var.project}-${var.environment}-task-definition"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_ecs_service" "age_service" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.age_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.age_task_defintion.arn
  desired_count   = var.ecsReplicas

  network_configuration {
    security_groups = var.ecsTaskSecurityGroupIds
    subnets         = var.ecsTaskSubnetIds
  }

  load_balancer {
    target_group_arn = var.ecsTargetGroupId
    container_name   = "${var.project}-${var.environment}-task-definition"
    container_port   = var.ecsContainerPort
  }
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  
  tags = {
    Name = "${var.project}-${var.environment}-service"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
  
  # [after initial apply] don't override changes made to task_definition
  # from outside of terraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_cloudwatch_log_group" "age_ecs_log_group" {
  name              = "/fargate/service/${var.project}-${var.environment}"
  retention_in_days = var.ecsLogsRetentionInDays
  tags = {
    Name = "${var.project}-${var.environment}-ecs-log-group"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_appautoscaling_target" "age_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.age_cluster.name}/${aws_ecs_service.age_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecsAutoscaleMaxInstances
  min_capacity       = var.ecsAutoscaleMinInstances
}


resource "aws_cloudwatch_metric_alarm" "age_high_cpu_utilization_alarm" {
  alarm_name          = "${var.project}-${var.environment}-high-cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecsAutoScalingUpperThreshold

  dimensions = {
    ClusterName = aws_ecs_cluster.age_cluster.name
    ServiceName = aws_ecs_service.age_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.age_scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "age_low_cpu_utilization_alarm" {
  alarm_name          = "${var.project}-${var.environment}-low-cpu-utilization-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecsAutoScalingLowerThreshold

  dimensions = {
    ClusterName = aws_ecs_cluster.age_cluster.name
    ServiceName = aws_ecs_service.age_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.age_scale_down_policy.arn]
}

resource "aws_appautoscaling_policy" "age_scale_up_policy" {
  name               = "app-scale-up"
  service_namespace  = aws_appautoscaling_target.age_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.age_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.age_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "age_scale_down_policy" {
  name               = "app-scale-down"
  service_namespace  = aws_appautoscaling_target.age_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.age_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.age_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}