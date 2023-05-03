locals {
  tags = merge(
    {
      "name"      = "${var.name}-${var.environment}"
      "env"       = var.environment
      "CreatedBy" = "Terraform"
    },
    var.tags,
  )
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

output "id" {
  value = aws_s3_bucket.bucket.id
}

output "arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

