
# Create a Route 53 CNAME record for the n8n subdomain
resource "aws_route53_record" "helpers_route53_record" {
  zone_id = var.route53_hosted_zone_id
  name    = var.n8n_host # Subdomain
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name] # Point to the ALB
}