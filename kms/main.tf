
resource "aws_kms_key" "kms_key" {
  count                   = var.kms_enabled ? 1 : 0
  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  policy                  = var.kms_policy
  
  tags = merge(var.tags, { "Name" = "${var.project}-${var.env}-kms" })
}

resource "aws_kms_alias" "kms_alias" {
  count         = var.kms_enabled ? 1 : 0
  name          = "alias/${var.project}-${var.env}-kms"
  target_key_id = join("", aws_kms_key.kms_key.*.id)
}
