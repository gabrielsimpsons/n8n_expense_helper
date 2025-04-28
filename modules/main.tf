data "aws_availability_zones" "available" {
  state = "available"
}

module "helpers" {
    source = "./helpers"
    aws_region = var.aws_region
    helpers_root_password = var.helpers_root_password
    route53_hosted_zone_id = var.route53_hosted_zone_id
    alb_dns_name = aws_lb.gsierrar_alb.dns_name
    alb_dns_arn = aws_lb.gsierrar_alb.arn
    security_group_id = aws_security_group.gsierrar_sg.id
    subnet_public_ids = {
        subnet1 = aws_subnet.gsierrar_subnet_public[0].id
        subnet2 = aws_subnet.gsierrar_subnet_public[1].id
    }
    subnet_id = aws_subnet.gsierrar_subnet_public[0].id
    vpc_id = aws_vpc.gsierrar_vpc.id
    vpc_cidr = aws_vpc.gsierrar_vpc.cidr_block
    n8n_host = var.n8n_host
    n8n_webhook_url = var.n8n_webhook_url
}

output "alb_dns_name" {
  value = aws_lb.gsierrar_alb.dns_name
}


output "alb_dns_arn" {
  value = aws_lb.gsierrar_alb.arn
}
