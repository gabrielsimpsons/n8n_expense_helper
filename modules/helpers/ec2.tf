data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # Ubuntu 22.04 LTS
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "helpers_key" {
  key_name   = "helpers-key" # Name of the key pair
  public_key = file("${path.module}/helpers-key.pub") # Path to the public key file
}

# user_data is not executed by default, so we need to connect via SSH and execute 
# docker run --rm -p 5678:5678 \
#    --name helpers \
#    -v helpers_data:/home/node/.n8n \
#    -e WEBHOOK_URL=https://helpers.gsierrar.dev/webhook \
#    -e N8N_BASIC_AUTH_ACTIVE=true \
#    -e N8N_BASIC_AUTH_USER=admin \
#    -e N8N_BASIC_AUTH_PASSWORD=your_secure_password \
#    -e N8N_HOST=helpers.gsierrar.dev \
#    -e N8N_PORT=5678 \
#    -e N8N_PROTOCOL=http \
#    n8nio/n8n
resource "aws_instance" "helpers_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium" # Increased resources for better performance
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id, aws_security_group.helpers_instance_sg.id]
  key_name      = "helpers-key" # replace with your key
  user_data     = templatefile("${path.module}/helpers_user_data.tpl", {
    webhook_url       = var.n8n_webhook_url,
    helpers_root_password = var.helpers_root_password,
    n8n_host          = var.n8n_host,
  })
  tags = {
    Name = "helpers-instance"
  }
  root_block_device {
    volume_size = 8 # keep it small.
  }
}

# Resource for creating an Elastic IP
resource "aws_eip" "helpers_eip" {
  associate_with_private_ip = aws_instance.helpers_instance.private_ip
}

# Resource for associating an Elastic IP
resource "aws_eip_association" "helpers_eip_assoc" {
  instance_id   = aws_instance.helpers_instance.id
  allocation_id = aws_eip.helpers_eip.id
}