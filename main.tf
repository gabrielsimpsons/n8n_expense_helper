# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket         = "peronalterraform"
  #   key            = "terraform/state"
  #   region         = "us-east-1"
    
  # }
}

provider "aws" {
  region = var.aws_region
}

module "gsierrar" {
  source = "./modules"
  aws_region = var.aws_region
  helpers_root_password = var.helpers_root_password
  route53_hosted_zone_id = var.route53_hosted_zone_id
}