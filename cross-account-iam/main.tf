resource "aws_iam_role" "cross_account" {
  name = "${var.project}-${var.environment}-eks-cross-account-role"
  assume_role_policy = data.aws_iam_policy_document.irsa.json
  tags = var.tags
}
resource "aws_iam_policy" "cross_account_rds_policy" {
  name        = "${var.environment}-cross-account-rds"
  description = "Cross Account IAM Policy for RDS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBClusterParameters",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBSecurityGroups",
          "rds:DescribeRecommendations",
          "rds:ListTagsForResource",
          "rds:DescribeRecommendationGroups",
          "rds:DownloadDBLogFilePortion",
          "rds:DescribeDBInstances",
          "rds:DescribeOptionGroupOptions",
          "rds:DescribeSourceRegions",
          "rds:DownloadCompleteDBLogFile",
          "rds:DescribeDBParameters",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterParameterGroups",
          "rds:DescribeOptionGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "cross_account_rds_policy_attachment" {
  name       = "${var.environment}-cross-account-rds-attachment"
  roles      = [aws_iam_role.cross_account.name]
  policy_arn = aws_iam_policy.cross_account_rds_policy.arn
}

resource "aws_iam_policy" "cross_account_secrets_manager_policy" {
  name        = "${var.environment}-cross-account-secrets-manager"
  description = "Cross Account IAM Policy for Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "cross_account_secrets_manager_policy_attachment" {
  name       = "${var.environment}-cross-account-secrets-manager-attachment"
  roles      = [aws_iam_role.cross_account.name]
  policy_arn = aws_iam_policy.cross_account_secrets_manager_policy.arn
}

resource "aws_iam_policy" "cross_account_elasticache_policy" {
  name        = "${var.environment}-cross-account-elasticache"
  description = "Cross Account IAM Policy for Elasticache"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "cross_account_elasticache_policy_attachment" {
  name       = "${var.environment}-cross-account-elasticache-attachment"
  roles      = [aws_iam_role.cross_account.name]
  policy_arn = aws_iam_policy.cross_account_elasticache_policy.arn
}

resource "aws_iam_policy" "cross_account_ssm_policy" {
  name        = "${var.environment}-cross-account-parameter-store"
  description = "Cross Account IAM Policy for Parameter Store"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "cross_account_ssm_policy_attachment" {
  name       = "${var.environment}-cross-account-parameter-store-attachment"
  roles      = [aws_iam_role.cross_account.name]
  policy_arn = aws_iam_policy.cross_account_ssm_policy.arn
}

resource "aws_iam_policy" "cross_account_acm_policy" {
  name        = "${var.environment}-cross-account-acm"
  description = "Cross Account IAM Policy for ACM Certificate"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "acm:ExportCertificate",
          "acm:GetAccountConfiguration",
          "acm:DescribeCertificate",
          "acm:GetCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "cross_account_acm_policy_attachment" {
  name       = "${var.environment}-cross-account-acm-attachment"
  roles      = [aws_iam_role.cross_account.name]
  policy_arn = aws_iam_policy.cross_account_acm_policy.arn
}
