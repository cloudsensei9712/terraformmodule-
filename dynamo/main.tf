resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${var.project}-${var.environment}-${var.table_name}"
  billing_mode   = var.table_billing_mode
  read_capacity  = var.table_read_capacity
  write_capacity = var.table_write_capacity
  hash_key       = var.table_hash_key
  range_key      = var.table_range_key

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled = true
  }
  attribute {
    name = var.table_hash_key
    type = "S"
  }
  attribute {
    name = var.table_range_key
    type = "S"
  }
  dynamic "attribute" {
    for_each = var.table_additional_attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.table_gsi
    content {
      name      = global_secondary_index.key
      hash_key  = global_secondary_index.value.hash_key
      range_key = global_secondary_index.value.range_key

      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  tags = var.tags
}