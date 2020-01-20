
resource "aws_acm_certificate" "pscloud-acm-cert" {
  domain_name                 = var.pscloud_domain_name
  validation_method           = "DNS"
  subject_alternative_names   = var.pscloud_subject_alternative_names

  tags = {
    Name = "${var.pscloud_company}_acm_cert_${var.pscloud_env}"
    Purpouse = "cert_for_${var.pscloud_domain_name}"
  }
}

resource "aws_route53_record" "pscloud-r53-record" {
  count                       = (var.pscloud_validate_by_r53 == true ? 1 : 0)

  name                        = aws_acm_certificate.pscloud-acm-cert.domain_validation_options.0.resource_record_name
  type                        = aws_acm_certificate.pscloud-acm-cert.domain_validation_options.0.resource_record_type
  zone_id                     = var.pscloud_zone_id
  records                     = [ aws_acm_certificate.pscloud-acm-cert.domain_validation_options.0.resource_record_value ]
  ttl                         = 60

  depends_on                  = [ aws_acm_certificate.pscloud-acm-cert ]
}

resource "aws_acm_certificate_validation" "pscloud-cert-validation" {
  count                       =  (var.pscloud_validate_by_r53 == true ? 1 : 0)

  certificate_arn             = aws_acm_certificate.pscloud-acm-cert.arn
  validation_record_fqdns     = [ aws_route53_record.pscloud-r53-record[count.index].fqdn ]

  timeouts {
    create = "120m"
  }
}