resource "aws_lambda_function" "ecs_scan" {
  s3_bucket = var.s3_bucket
  s3_key = var.s3_key
  function_name = "${var.environment}-ecs-task-monitoring"
  description   = "Function used to monitor the ECS task status. The 'Stopped' tasks found would be then published to an SNS topic."
  handler       = "ecs_task_monitoring.handler"
  role          = var.existing_policy ? data.aws_iam_role.existing_ecs_iam_role.arn : aws_iam_role.iam_ecs_task_monitoring[0].arn
  timeout       = 300
  environment {
    variables = {
      SNS_ARN         = data.aws_sns_topic.t.arn
      ENVIRONMENT = var.environment
    }
  }

  runtime = "python3.8"
}

resource "aws_cloudwatch_event_rule" "ecs_scan" {
    name = "trigger-lambda-${aws_lambda_function.ecs_scan.function_name}"
    description = "Trigger scan every 5 minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "trigger_5m" {
    rule = aws_cloudwatch_event_rule.ecs_scan.name
    target_id = "ecs_scan"
    arn = aws_lambda_function.ecs_scan.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ecs_scan" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_scan.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_scan.arn
}