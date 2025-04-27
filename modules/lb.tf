# Create an Application Load Balancer
resource "aws_lb" "gsierrar_alb" {
  name               = "n8n-alb"
  internal           = false # Make it public
  load_balancer_type = "application"
  security_groups    = [aws_security_group.n8n_sg.id] # Use the security group
  subnets            = [aws_subnet.n8n_subnet.id]       # Use the subnet
  ip_address_type    = "ipv4"

  tags = {
    Name = "n8n-alb"
  }
}