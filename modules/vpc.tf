# Create a VPC for the helpers instance
resource "aws_vpc" "gsierrar_vpc" {
  cidr_block = "10.0.0.0/16" # Define a CIDR block for the VPC
  tags = {
    Name = "gsierrar-vpc"
  }
}