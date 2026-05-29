resource "aws_route53_zone" "zone" {
  name    = var.domain
  comment = "DNS for ${var.domain}"
}

resource "aws_route53domains_registered_domain" "domain" {
  provider           = aws.us_east_1
  count              = var.update_registrar ? 1 : 0
  domain_name        = var.domain
  auto_renew         = true
  transfer_lock      = true
  admin_privacy      = true
  registrant_privacy = true
  tech_privacy       = true
  billing_privacy    = true

  dynamic "name_server" {
    for_each = aws_route53_zone.zone.name_servers

    content {
      name = name_server.value
    }
  }

  lifecycle {
    ignore_changes = [
      admin_contact,
      registrant_contact,
      tech_contact,
      billing_contact
    ]
  }
}

// www redirect

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  type    = "CNAME"
  name    = "www"
  records = [var.domain]
  ttl     = var.default_ttl
}

// Email

resource "aws_route53_record" "mx" {
  count   = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type    = "MX"
  name    = var.domain
  records = [
    "10 ${var.email_configuration.mxa}",
    "10 ${var.email_configuration.mxb}",
  ]
  ttl = var.default_ttl
}

resource "aws_route53_record" "spf" {
  count   = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type    = "TXT"
  name    = var.domain
  records = [var.email_configuration.spf]
  ttl     = var.default_ttl
}

resource "aws_route53_record" "dkim" {
  count   = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type    = "TXT"
  name    = "pic._domainkey.${var.domain}"
  records = [var.email_configuration.dkim]
  ttl     = var.default_ttl
}
