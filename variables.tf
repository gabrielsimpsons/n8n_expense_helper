# Define input variables for sensitive information and configuration
variable "aws_region" {
  description = "The AWS region to deploy resources to."
  type        = string
  default     = "us-east-1" # Change this to your desired region
}

variable "n8n_root_password" {
  description = "The initial root password for the n8n instance.  **IMPORTANT: Keep this secure!**"
  type        = string
  sensitive   = true
}

variable "route53_hosted_zone_id" {
  description = "The ID of the Route 53 hosted zone for the domain."
  type        = string
}

variable "efs_backup_policy_arn" {
  description = "Optional: The ARN of the EFS backup policy."
  type        = string
  default     = ""
}