data "aws_caller_identity" "current" {}

resource "aws_route53_zone" "zone" {
  name    = var.domain
  comment = "DNS for ${var.domain}"
}

// DNSSEC

resource "aws_kms_key" "key" {
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  description              = "Route 53 DNSSEC KSK for ${var.domain}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Allow Route 53 DNSSEC signing"
        Effect    = "Allow"
        Principal = { Service = "dnssec-route53.amazonaws.com" }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = aws_route53_zone.zone.arn
          }
        }
      },
      {
        Sid       = "Allow Route 53 DNSSEC to create grants"
        Effect    = "Allow"
        Principal = { Service = "dnssec-route53.amazonaws.com" }
        Action    = "kms:CreateGrant"
        Resource  = "*"
        Condition = {
          Bool = { "kms:GrantIsForAWSResource" = "true" }
        }
      },
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
    ]
  })
}

resource "aws_route53_key_signing_key" "signing_key" {
  hosted_zone_id             = aws_route53_zone.zone.id
  key_management_service_arn = aws_kms_key.key.arn
  name                       = replace(var.domain, ".", "_")
}

resource "aws_route53_hosted_zone_dnssec" "dnssec" {
  depends_on     = [aws_route53_key_signing_key.signing_key]
  hosted_zone_id = aws_route53_key_signing_key.signing_key.hosted_zone_id
}

resource "aws_route53domains_registered_domain" "domain" {
  count       = var.is_aws_domains ? 1 : 0
  domain_name = var.domain
  auto_renew = true
  transfer_lock = true
  admin_privacy = true
  registrant_privacy = true
  tech_privacy = true
  billing_privacy = true

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

resource "aws_route53domains_delegation_signer_record" "ds" {
  count       = var.is_aws_domains ? 1 : 0
  domain_name = var.domain

  signing_attributes {
    algorithm  = aws_route53_key_signing_key.signing_key.signing_algorithm_type
    flags      = aws_route53_key_signing_key.signing_key.flag
    public_key = aws_route53_key_signing_key.signing_key.public_key
  }

  depends_on = [
    aws_route53_hosted_zone_dnssec.dnssec,
    aws_route53domains_registered_domain.domain,
  ]
}

// www redirect

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  type    = "CNAME"
  name    = "www"
  records = [var.domain]
  ttl     = 1800
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
  ttl = 1800
}

resource "aws_route53_record" "spf" {
  count   = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type    = "TXT"
  name    = var.domain
  records = [var.email_configuration.spf]
  ttl     = 1800
}

resource "aws_route53_record" "dkim" {
  count   = var.email_configuration == null ? 0 : 1
  zone_id = aws_route53_zone.zone.zone_id
  type    = "TXT"
  name    = "pic._domainkey.${var.domain}"
  records = [var.email_configuration.dkim]
  ttl     = 1800
}
