# Define input variables for sensitive information and configuration
variable "aws_region" {
  description = "The AWS region to deploy resources to."
  type        = string
  default     = "us-east-1" # Change this to your desired region
}

variable "helpers_root_password" {
  description = "The initial root password for the n8n instance.  **IMPORTANT: Keep this secure!**"
  type        = string
  sensitive   = true
}

variable "route53_hosted_zone_id" {
  description = "The ID of the Route 53 hosted zone for the domain."
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_dns_arn" {
  description = "The DNS ARM of the Application Load Balancer"
  type        = string
}


variable "security_group_id" {
  description = "Security "
  type        = string
}

variable "subnet_id" {
  description = "subnet id"
  type        = string
}


variable "vpc_id" {
  description = "subnet id"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
}

variable "subnet_public_ids" {
    description = "A map of public subnet IDs where resources will be created"
    type        = map(string)
}

variable "n8n_host" {
  description = "The hostname for the n8n instance."
  type        = string
}

variable "n8n_webhook_url" {
  description = "webhook url for n8n instance."
  type        = string
}