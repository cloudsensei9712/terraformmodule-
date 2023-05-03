#Terraform AD template

# AD Password
data "aws_secretsmanager_secret_version" "ad_password" {
  secret_id = var.ad_password_secrets_arn
}

#MicoSoft AD
resource "aws_directory_service_directory" "ad" {
  count      = var.ad_enabled ? 1 : 0
  name       = var.ad_full_name
  short_name = var.ad_short_name
  type       = var.ad_type
  edition    = var.ad_edition
  size       = var.ad_size
  password   = data.aws_secretsmanager_secret_version.ad_password.secret_string

  vpc_settings {
    vpc_id     = var.ad_vpc_id
    subnet_ids = var.ad_subnet_id_list
  }

  lifecycle {
    ignore_changes = [password]
  }

  tags = var.tags
}
