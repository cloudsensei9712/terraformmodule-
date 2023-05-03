resource "aws_flow_log" "flow_log" {
  log_destination      = var.s3_bucket
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  destination_options {
    file_format        = "parquet"
    per_hour_partition = true
  }
  tags = var.tags
}