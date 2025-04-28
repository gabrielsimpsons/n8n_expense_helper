

# Create a Target Group for the ALB
resource "aws_lb_target_group" "helpers_tg" {
  name        = "helpers-tg"
  port        = 5678
  protocol    = "HTTP" # Use HTTP, the ALB will handle HTTPS termination.
  vpc_id      = var.vpc_id
  target_type = "instance" # Target the EC2 instance
  
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
  
}

# Attach the EC2 instance to the Target Group
resource "aws_lb_target_group_attachment" "helpers_tg_attachment" {
  target_group_arn = aws_lb_target_group.helpers_tg.arn
  target_id        = aws_instance.helpers_instance.id
  port             = 5678
}