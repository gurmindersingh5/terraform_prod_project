output "alb_domain" {
  value = aws_lb.alb-for-autoscaling-group.dns_name
}

