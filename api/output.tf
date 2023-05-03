output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_api_gateway_rest_api.api_gateway.execution_arn
}