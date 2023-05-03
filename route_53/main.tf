resource "aws_route53_record" "route_53_a_record" {
  zone_id = var.zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
