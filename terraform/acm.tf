# terraform/acm.tf
resource "aws_acm_certificate" "monitoring_cert" {
  domain_name       = var.monitor_domain # e.g., "monitor.example.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "monitoring-cert"
  }
}


#NOTE:
#The domain is on GoDaddy, so we are not using aws_acm_certificate_validation here.
#After requesting the certificate, add the CNAME validation record (shown in the ACM console or Terraform output)  
#to the GoDaddy DNS zone. Once the status becomes "Issued", the HTTPS listener apply will work correctly.

