resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.ses_domain
}

resource "aws_ses_template" "aws_ses_template" {
  name    = "${var.project}-${var.environment}-ses-template"
  subject = "Greetings, {{name}}!"
  html    = "<h1>Hello {{name}},</h1><p>Your favorite animal is {{favoriteanimal}}.</p>"
  text    = "Hello {{name}},\r\nYour favorite animal is {{favoriteanimal}}."
}