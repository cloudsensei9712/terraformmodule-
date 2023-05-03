output "dbMonitoringRoleArn" {
  value = aws_iam_role.age_db_monitoring_role.arn
}

output "ecsTaskExecutionRoleArn" {
  value = aws_iam_role.age_ecs_task_execution_role.arn
}

output "codebuildRoleArn" {
  value = aws_iam_role.age_codebuild_role.arn
}

output "codepipelineRoleArn" {
  value = aws_iam_role.age_codepipeline_role.arn
}

output "frontendCodepipelineRoleArn" {
  value = aws_iam_role.frontend_codepipeline_role.arn
}

output "lambdaExecutionRole" {
  value = aws_iam_role.lambda_role.arn
}


