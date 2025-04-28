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
  profile = var.aws_profile
}

module "gsierrar" {
  source = "./modules"
  aws_region = var.aws_region
  helpers_root_password = var.helpers_root_password
  route53_hosted_zone_id = var.route53_hosted_zone_id
  n8n_webhook_url = var.n8n_webhook_url
  n8n_host = var.n8n_host
}