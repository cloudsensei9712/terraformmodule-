resource "aws_acm_certificate" "certficate" {
  domain_name       = var.certificate_domain_name
  subject_alternative_names = var.certificate_alternate_domain_name
  validation_method = var.certificate_validation_method

  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}