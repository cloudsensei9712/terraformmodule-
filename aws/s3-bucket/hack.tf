variable "lifecycle_policy" {
  type        = string
  default     = "[]"
  description = "[Optional] Used to add a lifecycle policy to objects in an s3 bucket"
}

locals {
  object_expiry_days_rule = jsonencode([
    {
      abort_incomplete_multipart_upload_days = 1,
      enabled                                = true,
      id                                     = "${var.object_expiry_days}expiration",
      tags                                   = {},
      expiration = [
        {
          days                         = var.object_expiry_days,
          expired_object_delete_marker = false
        }
      ],
      noncurrent_version_expiration = [
        {
          days = 1
        }
      ]
    },
    {
      abort_incomplete_multipart_upload_days = 0,
      enabled                                = true,
      id                                     = "deleteexpired",
      tags                                   = {},
      expiration = [
        {
          days                         = 0,
          expired_object_delete_marker = true
        }
      ]
    }
  ])

  lifecycle_rule           = var.object_expiry_days == 0 ? var.lifecycle_policy : local.object_expiry_days_rule
  bucket_name              = var.bucket_name == "" ? "${var.name}-${var.environment}" : var.bucket_name
  var_policy               = var.policy == "" ? "{}" : var.policy
  restrict_read_obj_policy = length(var.allowed_object_reader_arns) > 0 ? module.restricted-object-read-s3-bucket-policy.json : "{}"

  ## Somewhat clumsy implementation, but I believe it is necessary to limit churn with existing buckets
  final_bucket_policy = local.var_policy == "{}" && local.restrict_read_obj_policy == "{}" ? "" : data.aws_iam_policy_document.generated_bucket_policy.json
}

module "restricted-object-read-s3-bucket-policy" {
  source = "../../../policies/resource/s3/restricted-object-read"
  create = length(var.allowed_object_reader_arns) > 0 ? true : false

  s3_bucket_name             = local.bucket_name
  allowed_object_reader_arns = var.allowed_object_reader_arns

}

data "aws_iam_policy_document" "generated_bucket_policy" {
  source_policy_documents = [
    local.var_policy,
    local.restrict_read_obj_policy
  ]
}

resource "aws_s3_bucket" "bucket" {
  acl    = "private"
  bucket = local.bucket_name

  tags = local.tags

  policy = local.final_bucket_policy

  acceleration_status = var.acceleration_status

#  disabled for now
#  logging {
#   target_bucket = var.logging_bucket_name
#    target_prefix = var.logging_prefix == "" ? "${var.name}-${var.environment}" : var.logging_prefix
#  }

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = var.kms_key_arn != "" ? "aws:kms" : "AES256"
      }
    }
  }

  dynamic "object_lock_configuration" {
    for_each = var.object_lock_enabled == true ? [true] : []
    content {
      object_lock_enabled = "Enabled"
      dynamic "rule" {
        for_each = (var.object_lock_rule_retention_mode != null) || (var.object_lock_rule_retention_days != null) ? [true] : []
        content {
          default_retention {
            mode = var.object_lock_rule_retention_mode
            days = var.object_lock_rule_retention_days
          }
        }
      }
    }
  }

  dynamic "cors_rule" {
    for_each = jsondecode(var.cors_rules)
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers")
      allowed_methods = lookup(cors_rule.value, "allowed_methods")
      allowed_origins = lookup(cors_rule.value, "allowed_origins")
      expose_headers  = lookup(cors_rule.value, "expose_headers")
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds")
    }
  }

  dynamic "lifecycle_rule" {
    for_each = jsondecode(local.lifecycle_rule)

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = lookup(lifecycle_rule.value, "expiration", [])

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_expiration", [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}
