resource "aws_s3_bucket" "s3_bucket" {
  count = var.bucket_count
  bucket = var.bucket_names[count.index]
  
  lifecycle {
    prevent_destroy = false
  }
  
  tags = var.tags

}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  count = var.bucket_count
  bucket = aws_s3_bucket.s3_bucket[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  count = var.bucket_count
  bucket = aws_s3_bucket.s3_bucket[count.index].id
  acl    = var.bucket_acls[count.index]
}

