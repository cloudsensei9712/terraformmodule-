
resource "aws_secretsmanager_secret" "secret" {
  count       = var.secret_count
  name        = "${var.project}-${var.environment}-${var.secret_name[count.index]}"
  description = var.secret_description
  kms_key_id  = var.secret_kms_key_id
  recovery_window_in_days  = var.secret_recovery_window_in_days

  tags = merge(var.tags, { "Name" = "${var.project}-${var.environment}-${var.secret_name[count.index]}" })
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  count         = (var.secret_count > 0) && var.secret_version_enabled ? 1 : 0
  secret_id     = join("", aws_secretsmanager_secret.secret[*].id)
  secret_string = var.secret_string
}