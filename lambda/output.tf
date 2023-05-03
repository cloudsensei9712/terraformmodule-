output "lambda_function_arn" {
  description = "Lambda Function Arn"
  value       = aws_lambda_function.function[*].arn
}

output "lambda_function_invoke_arn" {
  description = "Lambda Function Invoke Arn"
  value       = aws_lambda_function.function[*].invoke_arn
}



