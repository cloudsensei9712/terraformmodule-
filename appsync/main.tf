resource "aws_appsync_graphql_api" "api" {
  authentication_type = "AWS_IAM"
  name                = "${var.project}-${var.environment}-appsync"
  schema              = file("${path.module}/schema.graphql")

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.graph_log_role.arn
    field_log_level          = "ALL"
    exclude_verbose_content  = false
  }

  additional_authentication_provider {
    authentication_type = "API_KEY"
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.project}-${var.environment}-appsync-logs"

  tags = {
    application = "graph"
  }
}

#### AppSync Utilities ####

data "aws_iam_policy_document" "graph_log_role" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "graph_log_role" {
  name = "${var.project}-${var.environment}-appsync-role"

  assume_role_policy = data.aws_iam_policy_document.graph_log_role.json
}

data "aws_iam_policy_document" "graph_log_policy" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "graph_log" {
  name   = "${var.project}-${var.environment}-appsync-policy"
  role   = aws_iam_role.graph_log_role.id
  policy = data.aws_iam_policy_document.graph_log_policy.json
}

 ####-------------------------------------------> AppSync
resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${var.environment}-appsync-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
}


data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_function" "lambda" {
  s3_bucket     = var.lambda_function_s3_bucket
  s3_key        = var.lambda_function_s3_key
  function_name = "${var.project}-${var.environment}-appsync-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "src.main.hello_world"

  runtime = "python3.8"
}


#### AppSync Wiring ####

data "aws_iam_policy_document" "hello_world_service" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_service_role" {
  name = "${var.project}-${var.environment}-appsync-lambda-service-role"

  assume_role_policy = data.aws_iam_policy_document.hello_world_service.json
}


data "aws_iam_policy_document" "lambda_service_role_policy_document" {
  statement {
    sid = "1"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [aws_lambda_function.lambda.arn]
  }
}

resource "aws_iam_role_policy" "lambda_service_role_policy" {
  name   = "${var.project}-${var.environment}-appsync-lambda-service-role-policy"
  role   = aws_iam_role.lambda_service_role.id
  policy = data.aws_iam_policy_document.lambda_service_role_policy_document.json
}

resource "aws_appsync_datasource" "lambda_source" {
  api_id           = aws_appsync_graphql_api.api.id
  name             = "_${var.project}_${var.environment}_appsync_lambda_source"
  service_role_arn = aws_iam_role.lambda_service_role.arn
  type             = "AWS_LAMBDA"

  lambda_config {
    function_arn = aws_lambda_function.lambda.arn
  }
}

resource "aws_appsync_function" "appsync_lambda" {
  api_id                   = aws_appsync_graphql_api.api.id
  data_source              = aws_appsync_datasource.lambda_source.name
  name                     = "_${var.project}_${var.environment}_appsync_lambda"
  request_mapping_template = <<EOF
    {
        "version": "2017-02-28",
        "operation": "Invoke",
        "payload": {
            "field": "helloWorld",
            "arguments":  $utils.toJson({"greeting": $ctx.args.greeting})
        }
    }
  EOF

  response_mapping_template = <<EOF
    $utils.toJson($context.result)
  EOF
}

resource "aws_appsync_resolver" "lambda_resolver" {
  type              = "Query"
  api_id            = aws_appsync_graphql_api.api.id
  field             = "helloWorldLambda"
  request_template  = "{}"
  response_template = "$util.toJson($ctx.prev.result)"
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.appsync_lambda.function_id
    ]
  }
}