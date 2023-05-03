data "aws_caller_identity" "current" {
}

resource "aws_kms_key" "main" {
  description              = var.description
  enable_key_rotation      = var.customer_master_key_spec == "SYMMETRIC_DEFAULT" ? true : false
  policy                   = data.aws_iam_policy_document.final.json
  tags                     = var.tags
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
}

resource "aws_kms_alias" "main" {
  count = var.alias == "" ? 0 : 1

  name          = var.alias
  target_key_id = aws_kms_key.main.id
}

locals {
  allowed_aws_svcs = compact(
    [
      var.enable_sns ? "sns.amazonaws.com" : "",
      var.enable_s3 ? "s3.amazonaws.com" : "",
      var.enable_sqs ? "sqs.amazonaws.com" : "",
    ],
  )
  allowed_accounts = compact(concat(
    var.allowed_accounts,
    [data.aws_caller_identity.current.account_id]
  ))
}

# https://docs.aws.amazon.com/sns/latest/dg/sns-enable-encryption-for-topic-sqs-queue-subscriptions.html
data "aws_iam_policy_document" "allow_services" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "Service"
      identifiers = local.allowed_aws_svcs
    }

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "key_policy" {
  source_json   = var.enable_sns || var.enable_s3 || var.enable_sqs ? data.aws_iam_policy_document.allow_services.json : "{}"
  override_json = var.kms_iam_policy == "" ? "{}" : var.kms_iam_policy

  statement {
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    principals {
      type = "AWS"

      identifiers = local.allowed_accounts
    }

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "custom" {
  source_json = var.additional_policy_json != "" ? var.additional_policy_json : "{}"
}

data "aws_iam_policy_document" "final" {
  source_json   = data.aws_iam_policy_document.key_policy.json
  override_json = data.aws_iam_policy_document.custom.json
}
