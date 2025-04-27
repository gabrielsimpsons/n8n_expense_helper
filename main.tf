# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source for the AWS AMI.  We'll use Amazon Linux 2 because it is a good
# general purpose and relatively lightweight choice.
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ami-amazon-linux-2-x86_64-gp2"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Create an EFS file system
resource "aws_efs_file_system" "n8n_efs" {
  #  Apply the backup policy if provided
  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS" # Save on costs
  }
  tags = {
    Name = "n8n-efs"
  }
}
# Apply backup policy if provided
resource "aws_efs_backup_policy" "n8n_efs_backup_policy" {
  count = var.efs_backup_policy_arn != "" ? 1 : 0
  file_system_id = aws_efs_file_system.n8n_efs.id
  backup_policy {
    status = "ENABLED"
  }
}


# Create an EFS mount target.  This allows an EC2 instance to mount the EFS volume.
resource "aws_efs_mount_target" "n8n_efs_mount_target" {
  file_system_id  = aws_efs_file_system.n8n_efs.id
  subnet_id      = aws_subnet.n8n_subnet.id # Use the subnet created below
  security_groups = [aws_security_group.n8n_sg.id]
}

# Create a security group for the n8n instance
resource "aws_security_group" "n8n_sg" {
  name        = "n8n-sg"
  description = "Allow traffic to n8n"
  vpc_id      = aws_vpc.n8n_vpc.id # Use the VPC created below

  # Allow inbound traffic on port 80 (HTTP) and 443 (HTTPS)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting to your IP range
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting to your IP range
  }
  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "n8n-sg"
  }
}

# Create a VPC for the n8n instance
resource "aws_vpc" "n8n_vpc" {
  cidr_block = "10.0.0.0/16" # Define a CIDR block for the VPC
  tags = {
    Name = "n8n-vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "n8n_subnet" {
  vpc_id            = aws_vpc.n8n_vpc.id
  cidr_block        = "10.0.0.0/24" # Define CIDR block for the subnet
  availability_zone = "${var.aws_region}a" # You can choose a specific AZ
  tags = {
    Name = "n8n-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "n8n_igw" {
  vpc_id = aws_vpc.n8n_vpc.id
  tags = {
    Name = "n8n-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "n8n_route_table" {
  vpc_id = aws_vpc.n8n_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.n8n_igw.id
  }
  tags = {
    Name = "n8n-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "n8n_route_table_association" {
  subnet_id      = aws_subnet.n8n_subnet.id
  route_table_id = aws_route_table.n8n_route_table.id
}
# Create an EC2 instance to run n8n.  We'll use the t3.nano instance type
# as it's one of the cheapest available.  For the root volume, we will use the
# default, which is fine for this use case.
resource "aws_instance" "n8n_instance" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.nano" # Cheapest instance type
  subnet_id     = aws_subnet.n8n_subnet.id
  vpc_security_group_ids = [aws_security_group.n8n_sg.id]
  key_name      = "n8n-key" # replace with your key
  user_data     = templatefile("${path.module}/n8n_user_data.tpl", {
    n8n_root_password = var.n8n_root_password,
    efs_id            = aws_efs_file_system.n8n_efs.id
  })
  tags = {
    Name = "n8n-instance"
  }
  root_block_device {
    volume_size = 8 # keep it small.
  }
}

# Resource for creating an Elastic IP
resource "aws_eip" "n8n_eip" {
  vpc = true
}

# Resource for associating an Elastic IP
resource "aws_eip_association" "n8n_eip_assoc" {
  instance_id   = aws_instance.n8n_instance.id
  allocation_id = aws_eip.n8n_eip.id
}


# Create a Route 53 record to validate the ACM certificate
resource "aws_route53_record" "n8n_cert_validation_record" {
  name    = tolist(aws_acm_certificate.n8n_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.n8n_cert.domain_validation_options)[0].resource_record_type
  zone_id = var.route53_hosted_zone_id
  records = [tolist(aws_acm_certificate.n8n_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

# Wait for the certificate validation to complete
resource "aws_acm_certificate_validation" "n8n_cert_validation" {
  certificate_arn         = aws_acm_certificate.n8n_cert.arn
  validation_record_fqdns = [aws_route53_record.n8n_cert_validation_record.fqdn]
}



# Create a Target Group for the ALB
resource "aws_lb_target_group" "n8n_tg" {
  name        = "n8n-tg"
  port        = 80
  protocol    = "HTTP" # Use HTTP, the ALB will handle HTTPS termination.
  vpc_id      = aws_vpc.n8n_vpc.id
  target_type = "instance" # Target the EC2 instance
  health_check {
    path = "/" #  n8n is accessible by default on /
  }
}

# Attach the EC2 instance to the Target Group
resource "aws_lb_target_group_attachment" "n8n_tg_attachment" {
  target_group_arn = aws_lb_target_group.n8n_tg.arn
  target_id        = aws_instance.n8n_instance.id
  port              = 80 # traffic will arrive at the instance on port 80
}

# Create an ALB Listener for HTTPS
resource "aws_lb_listener" "n8n_listener_https" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.n8n_cert_validation.certificate_arn # Use validated certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_tg.arn
  }
}
# create a http to https redirection
resource "aws_lb_listener" "n8n_listener_http" {
  load_balancer_arn = aws_lb.n8n_alb.arn
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

# Create a Route 53 CNAME record for the n8n subdomain
resource "aws_route53_record" "n8n_route53_record" {
  zone_id = var.route53_hosted_zone_id
  name    = "helpers.gsierrar.dev" # Subdomain
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.n8n_alb.dns_name] # Point to the ALB
}
# EFS Mount point
output "efs_mount_point" {
  value = aws_efs_file_system.n8n_efs.id
}
# ALB DNS name
output "alb_dns_name" {
  value = aws_lb.n8n_alb.dns_name
}
