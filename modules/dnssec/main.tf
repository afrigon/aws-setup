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

// The DS record at the parent registrar is intentionally NOT managed here.
// `aws_route53domains_delegation_signer_record` has a deterministic bug: its
// post-create lookup filters on Flags + PublicKey, but GetDomainDetail does
// not return those fields, so the filter never matches and Create aborts
// with "empty result" after the DS has already been associated. Re-applying
// pushes duplicate DS records to the registrar.
//
// Bug:  https://github.com/hashicorp/terraform-provider-aws/issues/47928
// Fix:  https://github.com/hashicorp/terraform-provider-aws/pull/47932
//
// Until the fix ships, run the `dnssec_associate_command` output once after
// `apply` to register the DS at the registrar. To tear down, disassociate
// the DS manually before `terraform destroy` (see `dnssec_disassociate_command`),
// otherwise DisableHostedZoneDNSSEC fails with KeySigningKeyInParentDSRecord.
