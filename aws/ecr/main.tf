locals {
  tags = merge({ CreatedBy = "Terraform" }, var.tags)
}

resource "aws_ecr_repository" "repo" {
  name = var.name
  tags = local.tags

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_iam_policy_document" "cross_account_pull" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.allowed_accounts)
    }
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:GetRepositoryPolicy"
    ]
  }
}

data "aws_caller_identity" "current" {}

# Allow the Lambda service to retrieve images from the repository.
# NOTE: AWS automatically creates this policy if doesn't exist when a Lambda 
# function is deployed. To prevent AWS from doing that, we need to add it 
# ourselves, and it also needs to be identical to the standard one.
data "aws_iam_policy_document" "lambda_retrieval" {
  statement {
    sid    = "LambdaECRImageRetrievalPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:GetRepositoryPolicy"
    ]
    dynamic "condition" {
      for_each = length(var.allowed_accounts) == 0 ? [] : [1]
      content {
        test     = "StringLike"
        variable = "aws:sourceARN"
        values   = formatlist("arn:aws:lambda:*:%s:function:*", var.allowed_accounts)
      }
    }
  }
}

# Allow our dedicated ECR account (The CircleCIPublish role) with the ability
# to push images to this repository.
data "aws_iam_policy_document" "ecr-policy" {
  source_policy_documents = compact([
    length(var.allowed_accounts) > 0 ? data.aws_iam_policy_document.cross_account_pull.json : "",
    var.allow_lambda_retrieval ? data.aws_iam_policy_document.lambda_retrieval.json : ""
  ])

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.ecr_account_id}:root"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr-policy" {
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.ecr-policy.json
}

resource "aws_ecr_lifecycle_policy" "ecr-limit" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove all untagged images but one",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Expire dev images older than 30 days",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["dev-"],
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 30
      },
      "action": {
          "type": "expire"
      }
    },
    {
      "rulePriority": 3,
      "description": "Restrict total image count to 9000",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 9000
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
