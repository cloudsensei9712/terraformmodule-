output "s3_bucket_name" {
  description = "AWS S3 bucket name"
  value       = aws_s3_bucket.s3_bucket[*].bucket 
}
output "s3_bucket_id" {
  description = "AWS S3 bucket id"
  value       = aws_s3_bucket.s3_bucket[*].id 
}