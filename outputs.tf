output "lb_endpoint" {
  value = "https://${aws_route53_record.alb.name}"
}