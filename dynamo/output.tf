output "dynamo_Table_arn" {
  description = "Dynamo DB Table Arn"
  value       = aws_dynamodb_table.dynamodb_table.arn
}

