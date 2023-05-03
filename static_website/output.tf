output "s3_bucket_name" {
  description = "AWS S3 bucket name"
  value       = aws_s3_bucket.s3_bucket.bucket 
}

output "cdn_distribution_id" {
  description = "ID of the Cloud Front Distribution"
  value       = aws_cloudfront_distribution.s3_cdn_distribution.id 
}

output "cdn_distribution_arn" {
  description = "ARN of the Cloud Front Distribution"
  value       = aws_cloudfront_distribution.s3_cdn_distribution.arn 
}
