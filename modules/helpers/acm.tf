# Create a Certificate Manager certificate for the n8n subdomain
resource "aws_acm_certificate" "n8n_cert" {
  domain_name               = "helpers.gsierrar.dev"
  subject_alternative_names = ["helpers.gsierrar.dev"] # Optional, but good to have.
  validation_method         = "DNS"

  tags = {
    Name = "n8n-certificate"
  }
}