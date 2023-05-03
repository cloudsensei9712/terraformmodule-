resource "aws_api_gateway_rest_api" "api_gateway" {
  name          ="${var.project}-${var.environment}-api"
  endpoint_configuration {
    types = ["REGIONAL"] //variable
  }

}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  count = var.lambda_functions_count
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.lambda_function_name[count.index]
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "api_gateway_method" {
  count = var.lambda_functions_count
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource[count.index].id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_stage" "api_gateway_stage" {
  count = var.lambda_functions_count
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.lambda_function_name[count.index]
}
resource "aws_api_gateway_integration" "api_gateway_integration" {
  count = var.lambda_functions_count
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_resource[count.index].id
  http_method             = aws_api_gateway_method.api_gateway_method[count.index].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn[count.index]
}


resource "aws_lambda_permission" "api_gateway_lambda_permissions" {
  count = var.lambda_functions_count
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name ="${var.project}-${var.environment}-${var.lambda_function_name[count.index]}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}