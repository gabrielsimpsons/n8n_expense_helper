resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS traffic for EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "helpers_instance_sg" {
  name_prefix = "helpers-instance-sg-"
  vpc_id      = var.vpc_id # Adjust if not using default VPC

  ingress {
    from_port   = 5678 # Assuming your n8n container exposes port 5678
    to_port     = 5678
    protocol    = "tcp"
    security_groups = [var.security_group_id] # Only allow traffic from the ALB
    cidr_blocks = [var.vpc_cidr] 
  }

  # Add other necessary ingress rules for your instance (e.g., SSH)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "Production"
    Project     = "helpers"
  }

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (use cautiously)
  # }
}