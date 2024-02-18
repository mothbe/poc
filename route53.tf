data "aws_route53_zone" "poc" {
  name = var.domain
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.poc.zone_id
  name    = "${var.domain_prefix}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.poc.dns_name
    zone_id                = aws_lb.poc.zone_id
    evaluate_target_health = true
  }
}