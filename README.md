# All my stack managed by terraform

## Certificate
user ssh-gen to create a new certificate and store it in `/modules/helpers/helpers-key`
```bash
ssh-keygen -t rsa -b 2048 -f helpers-key
```

## Variables
Create a `terraform.tfvars` in the root folder including:
- aws_region: AWS region
- helpers_root_password: Strong password for n8n
- route53_hosted_zone_id: if you're running it within your domain and already registered the zone id in Route53
- aws_profile: profile configured in aws cli

## helpers
- n8n instance running in EC2 instance. the smallest instance
- Load balancer to support all deployed components


sudo systemctl daemon-reload


sudo systemctl start n8n


sudo systemctl status n8n

sudo cat /var/log/cloud-init-output.log