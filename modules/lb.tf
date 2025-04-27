# Create an Application Load Balancer
resource "aws_lb" "gsierrar_alb" {
  name               = "gsierrar-alb"
  internal           = false # Make it public
  load_balancer_type = "application"
  security_groups    = [aws_security_group.gsierrar_sg.id] # Use the security group
  subnets            = [aws_subnet.gsierrar_subnet_public[0].id, aws_subnet.gsierrar_subnet_public[1].id]       # Use the subnet
  ip_address_type    = "ipv4"

  tags = {
    Name = "gsierrar-alb"
  }
}