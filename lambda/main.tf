
# Lambda Layer
resource "aws_lambda_layer_version" "lambda_layer" {
  count = var.lambda_functions_count
  s3_bucket   = var.lambda_function_s3_bucket
  s3_key      = var.lambda_layer_s3_key[count.index]
  layer_name = "${var.project}-${var.environment}-${var.lambda_function_name[count.index]}-layer"

  compatible_runtimes = [  var.lambda_function_runtime[count.index] ] 
}
#Lambda Functions
resource "aws_lambda_function" "function" {
  count = var.lambda_functions_count
  function_name = "${var.project}-${var.environment}-${var.lambda_function_name[count.index]}"
  role = var.lambda_role
  s3_bucket     = var.lambda_function_s3_bucket
  s3_key        = var.lambda_function_s3_key[count.index]
  handler       = var.lambda_function_handler[count.index]
  runtime       = var.lambda_function_runtime[count.index]
  layers        = [ aws_lambda_layer_version.lambda_layer[count.index].arn ]
  vpc_config {
    subnet_ids         = var.lambda_function_subnets
    security_group_ids = var.lambda_function_security_group
  }
  ephemeral_storage {
    size = 10240 # Min 512 MB and the Max 10240 MB
  }
  tags = {
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}


# resource "aws_lambda_permission" "allow_api" {
#   count = var.lambda_functions_count
#   statement_id  = "AllowAPIgatewayInvokation"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.function[count.index].invoke_arn
#   principal     = "apigateway.amazonaws.com"
# }