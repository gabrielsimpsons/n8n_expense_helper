variable "aws_region" {
  description = "The AWS region to deploy resources to."
  type        = string
  default     = "us-east-1" # Change this to your desired region
}

variable "aws_profile" {
  description = "The AWS aws_profile."
  type        = string
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

variable "efs_backup_policy_arn" {
  description = "Optional: The ARN of the EFS backup policy."
  type        = string
  default     = ""
}

variable "n8n_host" {
  description = "The hostname for the n8n instance."
  type        = string
}

variable "n8n_webhook_url" {
  description = "webhook url for n8n instance."
  type        = string
}