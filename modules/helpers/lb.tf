

# Create an ALB Listener for HTTPS
resource "aws_lb_listener" "helpers_listener_https" {
  load_balancer_arn = var.alb_dns_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.helpers_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.helpers_tg.arn
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "helpers_listener_http" {
  load_balancer_arn = var.alb_dns_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}