resource "aws_iam_policy" "ecs-task-monitoring-policy" {
  count = var.existing_policy ? 0 : 1
  name = "${var.environment}-ecs-task-monitoring"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecs:ListServices",
                "ecs:ListTasks",
                "ecs:ListClusters",
                "ecs:DescribeServices",
                "ecs:DescribeTasks"
            ],
            "Resource": "*"
        },
        {
            "Sid": "3",
            "Action": [
              "logs:CreateLogGroup",
              "logs:PutLogEvents",
              "logs:CreateLogStream",
              "logs:Filter*",
              "logs:Describe*",
              "logs:List*",
              "logs:Get*"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        },
        {
          "Action": [
            "sns:Publish"
          ],
          "Resource": "${data.aws_sns_topic.t.arn}",
          "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role" "iam_ecs_task_monitoring" {
  count = var.existing_policy ? 0 : 1
  name = "${var.environment}-ecs-task-monitoring"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "att" {
  count = var.existing_policy ? 0 : 1
  role = aws_iam_role.iam_ecs_task_monitoring[0].name
  policy_arn = aws_iam_policy.ecs-task-monitoring-policy[0].arn
}