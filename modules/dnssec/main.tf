data "aws_caller_identity" "current" {}

resource "aws_kms_key" "key" {
  provider                 = aws.us_east_1
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
          StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
          ArnLike      = { "aws:SourceArn" = "arn:aws:route53:::hostedzone/*" }
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
  hosted_zone_id             = var.zone_id
  key_management_service_arn = aws_kms_key.key.arn
  name                       = replace(var.domain, ".", "_")
}

resource "aws_route53_hosted_zone_dnssec" "dnssec" {
  hosted_zone_id = aws_route53_key_signing_key.signing_key.hosted_zone_id
}

// Wait for DS removal at the parent to propagate before disabling DNSSEC.
// DisableHostedZoneDNSSEC checks the parent and fails if the DS is still there.
resource "time_sleep" "wait_for_ds_propagation" {
  depends_on       = [aws_route53_hosted_zone_dnssec.dnssec]
  destroy_duration = "300s"
}

resource "aws_route53domains_delegation_signer_record" "ds" {
  provider    = aws.us_east_1
  domain_name = var.domain

  signing_attributes {
    algorithm  = aws_route53_key_signing_key.signing_key.signing_algorithm_type
    flags      = aws_route53_key_signing_key.signing_key.flag
    public_key = aws_route53_key_signing_key.signing_key.public_key
  }

  depends_on = [
    time_sleep.wait_for_ds_propagation,
  ]
}
