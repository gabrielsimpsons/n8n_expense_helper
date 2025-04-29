# Create a Certificate Manager certificate for the n8n subdomain
# resource "aws_acm_certificate" "helpers_cert1" {
#   domain_name               = "helpers.gsierrar.dev"
#   subject_alternative_names = ["helpers.gsierrar.dev"] # Optional, but good to have.
#   validation_method         = "DNS"

#   tags = {
#     Name = "helpers-certificate"
#   }
# }

resource "aws_acm_certificate" "helpers_cert" {
  domain_name               = var.n8n_host
  subject_alternative_names = [var.n8n_host] # Optional, but good to have.
  validation_method         = "DNS"

  tags = {
    Name = "helpers-certificate"
  }
}

# Create a Route 53 record to validate the ACM certificate
resource "aws_route53_record" "helpers_cert_validation_record" {
  name    = tolist(aws_acm_certificate.helpers_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.helpers_cert.domain_validation_options)[0].resource_record_type
  zone_id = var.route53_hosted_zone_id
  records = [tolist(aws_acm_certificate.helpers_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

# Wait for the certificate validation to complete
resource "aws_acm_certificate_validation" "helpers_cert_validation" {
  certificate_arn         = aws_acm_certificate.helpers_cert.arn
  validation_record_fqdns = [aws_route53_record.helpers_cert_validation_record.fqdn]
  depends_on = [ aws_route53_record.helpers_cert_validation_record ]
}
