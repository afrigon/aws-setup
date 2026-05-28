resource "aws_route53_zone" "zone" {
  name = var.domain
  comment = "DNS for ${var.domain}"
}

// www redirect

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  type = "CNAME"
  name = "www"
  records = [var.domain]
  ttl = 1800
}

// Email

resource "aws_route53_record" "mx" {
  count = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type = "MX"
  name = var.domain
  records = [
    "10 ${var.email_configuration.mxa}",
    "10 ${var.email_configuration.mxb}",
  ]
  ttl = 1800
}

resource "aws_route53_record" "spf" {
  count = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type = "TXT"
  name = var.domain
  records = [var.email_configuration.spf]
  ttl = 1800
}

resource "aws_route53_record" "dkim" {
  count = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type = "TXT"
  name = "pic._domainkey.${var.domain}"
  records = [var.email_configuration.dkim]
  ttl = 1800
}