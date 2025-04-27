# Create a security group for the n8n instance
resource "aws_security_group" "gsierrar_sg" {
  name        = "gsierrar-sg"
  description = "Allow traffic to gsierrar"
  vpc_id      = aws_vpc.gsierrar_vpc.id # Use the VPC created below

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
    Name = "gsierrar-sg"
  }
}

# Create a Subnet
resource "aws_subnet" "gsierrar_subnet_public" {
  count                   = 2
  vpc_id                  = aws_vpc.gsierrar_vpc.id
  cidr_block              = "10.0.${count.index}.0/24" # Use /24 to avoid overlap
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "gsierrar-subnet-public-${count.index}"
  }

  depends_on = [data.aws_availability_zones.available, aws_vpc.gsierrar_vpc]
}

resource "aws_subnet" "gsierrar_subnet_private" {
  count             = 2
  vpc_id            = aws_vpc.gsierrar_vpc.id
  cidr_block        = "10.0.${count.index + 2}.0/24" # Use /24 and offset to avoid overlap
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "gsierrar-subnet-private-${count.index}"
  }

  depends_on = [aws_vpc.gsierrar_vpc, data.aws_availability_zones.available]
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gsierrar_igw" {
  vpc_id = aws_vpc.gsierrar_vpc.id
  tags = {
    Name = "gsierrar-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "gsierrar_route_table" {
  vpc_id = aws_vpc.gsierrar_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gsierrar_igw.id
  }
  tags = {
    Name = "gsierrar-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "gsierrar_route_table_association" {
  subnet_id      = aws_subnet.gsierrar_subnet_public[0].id
  route_table_id = aws_route_table.gsierrar_route_table.id
}