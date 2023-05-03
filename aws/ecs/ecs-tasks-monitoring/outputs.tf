output "ecs-lambda-arn"{
    description = "Lambda ECS arn"
    value = aws_lambda_function.ecs_scan.arn
}
