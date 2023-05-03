resource "aws_sns_topic" "sns_topic" {
  name              = var.sns_topic_name
  kms_master_key_id = "alias/aws/sns"
}