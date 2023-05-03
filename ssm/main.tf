# Terraform template to create SSM document
resource "aws_ssm_parameter" "foo" {
  count = "${var.project}-${var.environment}-${var.parameter_count}"
  name  = var.parameter_name[count.index]
  type  = var.parameter_type[count.index]
  value = var.parameter_value[count.index]
  tags = merge(var.tags, { "Name" = "${var.project}-${var.environment}-${var.parameter_name[count.index]}" })
}
