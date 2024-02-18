data "aws_acm_certificate" "cert" {
  domain      = "${var.domain_prefix}.${var.domain}"
  most_recent = true
}