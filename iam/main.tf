resource "aws_iam_role" "age_db_monitoring_role" {
  name = "${var.project}-${var.environment}-rds-monitoring-role"
  description = "The IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [ "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole" ]

  tags = {
    Name = "${var.project}-${var.environment}-rds-monitoring-role"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_iam_role" "age_ecs_task_execution_role" {
  name = "${var.project}-${var.environment}-ecs-task-execution-role"
  description = "The IAM role required for ECS Tasks"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [ "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" ]

  tags = {
    Name = "${var.project}-${var.environment}-ecs-task-execution-role"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# Codebuild role
resource "aws_iam_role" "age_codebuild_role" {
  name = "${var.project}-${var.environment}-codebuild-role"
  assume_role_policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          "Service": "codebuild.amazonaws.com"
        },
        Effect: "Allow"
      }
    ]
  }
  )
  path = "/"
}

resource "aws_iam_policy" "age_codebuild_logs_policy" {
  name        = "${var.project}-${var.environment}-codebuild-logs-policy"
  description = "Policy to give access to Code Build for CloudWatch Logs"
  policy = jsonencode(
  {
      Version: "2012-10-17",
      Statement: [
          {
              Effect: "Allow",
              Resource: [
                  "arn:aws:logs:${var.awsRegion}:${var.awsAccountId}:log-group:*"
              ],
              Action: [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ]
          }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "age_codebuild_logs_policy_attachment" {
  role       = aws_iam_role.age_codebuild_role.name
  policy_arn = aws_iam_policy.age_codebuild_logs_policy.arn
}

resource "aws_iam_policy" "age_codebuild_base_policy" {
  name        = "${var.project}-${var.environment}-codebuild-base-policy"
  policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Resource: [
                "arn:aws:logs:${var.awsRegion}:${var.awsAccountId}:log-group:${var.codeBuildLogGroupName}",
                "arn:aws:logs:${var.awsRegion}:${var.awsAccountId}:log-group:${var.codeBuildLogGroupName}:*"
            ],
            Action: [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            Effect: "Allow",
            Resource: [
                "arn:aws:s3:::*"
            ],
            Action: [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            Effect: "Allow",
            Action: [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            Resource: [
                "arn:aws:codebuild:${var.awsRegion}:${var.awsAccountId}:report-group/*"
            ]
        }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "age_codebuild_base_policy_attachment" {
  role       = aws_iam_role.age_codebuild_role.name
  policy_arn = aws_iam_policy.age_codebuild_base_policy.arn
}

resource "aws_iam_policy" "age_codebuild_vpc_policy" {
  name = "${var.project}-${var.environment}-codebuild-vpc-policy"
  policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "ec2:CreateNetworkInterfacePermission"
            ],
            Resource: "arn:aws:ec2:${var.awsRegion}:${var.awsAccountId}:network-interface/*",
            Condition: {
                "StringLike": {
                    "ec2:Subnet": [
                        "arn:aws:ec2:${var.awsRegion}:${var.awsAccountId}:subnet/*"
                    ],
                    "ec2:AuthorizedService": "codebuild.amazonaws.com"
                }
            }
        }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "age_codebuild_vpc_policy_attachment" {
  role       = aws_iam_role.age_codebuild_role.name
  policy_arn = aws_iam_policy.age_codebuild_vpc_policy.arn
}

resource "aws_iam_policy" "age_codebuild_ecr_policy" {
  name = "${var.project}-${var.environment}-codebuild-ecr-policy"
  policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
        {
            Resource: "*",
            Effect: "Allow",
            Action: [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ecr:GetAuthorizationToken"
            ]
        },
        {
            Resource: "arn:aws:s3:::*",
            Effect: "Allow",
            Action: [
                "s3:GetObject",
                "s3:PutObject",
                "s3:GetObjectVersion"
            ]
        },
        {
            Resource: "arn:aws:ecr:${var.awsRegion}:${var.awsAccountId}:repository/*",
            Effect: "Allow",
            Action: [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ]
        }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "age_codebuild_ecr_policy_attachment" {
  role       = aws_iam_role.age_codebuild_role.name
  policy_arn = aws_iam_policy.age_codebuild_ecr_policy.arn
}

resource "aws_iam_policy" "age_codebuild_ssm_policy" {
  name = "${var.project}-${var.environment}-codebuild-ssm-policy"
  policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
        {
            Resource: "*",
            Effect: "Allow",
            Action: [
                "ssm:DescribePatchGroups",
                "ssm:ListDocumentVersions",
                "ssm:DescribeMaintenanceWindowSchedule",
                "ssm:DescribeMaintenanceWindowTasks",
                "ssm:ListAssociationVersions",
                "ssm:ListInstanceAssociations",
                "ssm:GetParameter",
                "ssm:DescribeMaintenanceWindowExecutions",
                "ssm:DescribeMaintenanceWindowExecutionTaskInvocations",
                "ssm:DescribeMaintenanceWindowExecutionTasks",
                "ssm:ListOpsMetadata",
                "ssm:DescribeParameters",
                "ssm:ListResourceDataSync",
                "ssm:ListDocuments",
                "ssm:DescribeMaintenanceWindowsForTarget",
                "ssm:ListInventoryEntries",
                "ssm:ListComplianceItems",
                "ssm:GetParameterHistory",
                "ssm:DescribeSessions",
                "ssm:DescribeMaintenanceWindowTargets",
                "ssm:DescribePatchBaselines",
                "ssm:ListResourceComplianceSummaries",
                "ssm:DescribePatchProperties",
                "ssm:ListComplianceSummaries",
                "ssm:DescribeMaintenanceWindows",
                "ssm:ListAssociations"
            ]
        }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "age_codebuild_ssm_policy_attachment" {
  role       = aws_iam_role.age_codebuild_role.name
  policy_arn = aws_iam_policy.age_codebuild_ssm_policy.arn
}

resource "aws_iam_role" "age_codepipeline_role" {
  name = "${var.project}-${var.environment}-codepipeline-role"
  assume_role_policy = jsonencode(
  {
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          "Service": "codepipeline.amazonaws.com"
        },
        Effect: "Allow"
      }
    ]
  }
  )
  path               = "/"
}

resource "aws_iam_policy" "age_codepipeline_policy" {
  name = "${var.project}-${var.environment}-codepipeline-policy"
  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            Action: [
                "iam:PassRole"
            ],
            Resource: "*",
            Effect: "Allow",
            Condition: {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            Action: [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "codestar-connections:UseConnection"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Action: [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            Resource: "*",
            Effect: "Allow"
        },
        {
            Effect: "Allow",
            Action: [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "cloudformation:ValidateTemplate"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "ecr:DescribeImages"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            Resource: "*"
        },
        {
            Effect: "Allow",
            Action: [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            Resource: "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "age_codepipeline_policy_attachment" {
  role       = aws_iam_role.age_codepipeline_role.name
  policy_arn = aws_iam_policy.age_codepipeline_policy.arn
}