terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }

  backend "s3" {
    bucket       = "terraform-xehos"
    key          = "foundation.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

locals {
  owner        = "afrigon"
  state_bucket = "terraform-xehos"
}

// Resume Role

module "resume_role" {
  source = "../modules/ci-role"

  name         = "resume"
  state_bucket = local.state_bucket
  github = {
    owner      = local.owner
    repository = "resume"
  }

  permissions = [
    {
      actions = [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetBucketVersioning",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketTagging",
        "s3:GetBucketLogging",
        "s3:GetBucketWebsite",
        "s3:GetAccelerateConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketRequestPayment",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "cloudfront:CreateDistribution",
        "cloudfront:UpdateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:TagResource",
        "cloudfront:ListTagsForResource",
        "cloudfront:CreateOriginAccessControl",
        "cloudfront:UpdateOriginAccessControl",
        "cloudfront:DeleteOriginAccessControl",
        "cloudfront:GetOriginAccessControl",
        "cloudfront:GetResponseHeadersPolicy",
        "cloudfront:ListResponseHeadersPolicies",
        "cloudfront:GetCachePolicy",
        "cloudfront:ListCachePolicies",
        "cloudfront:CreateInvalidation",
        "acm:RequestCertificate",
        "acm:DeleteCertificate",
        "acm:DescribeCertificate",
        "acm:ListTagsForCertificate",
        "acm:AddTagsToCertificate",
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:GetHostedZone",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource",
        "route53:GetChange"
      ]
      resources = ["*"]
    }
  ]
}

// Minecraft Role

module "minecraft_role" {
  source = "../modules/ci-role"

  name         = "minecraft"
  state_bucket = local.state_bucket
  github = {
    owner      = local.owner
    repository = "minecraft-server"
  }
}

// xlang Role

module "xlang_role" {
  source = "../modules/ci-role"

  name         = "xlang"
  state_bucket = local.state_bucket
  github = {
    owner      = local.owner
    repository = "x-lang"
  }
}

locals {
  xlang_domain  = "x-lang.dev"
  frigon_domain = "frigon.app"
  home_ip       = "107.171.186.150"
  default_ttl   = 1800
}

# frigon.app dns

module "frigon_app_dns" {
  source = "../modules/dns"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain           = local.frigon_domain
  update_registrar = false
  email_configuration = {
    mxa  = "mxa.mailgun.org"
    mxb  = "mxb.mailgun.org"
    spf  = "v=spf1 include:mailgun.org ~all"
    dkim = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDaHU9ZpyHxZ1fKH2t3czU+OH7vsca9H5evUb1bfKhGuUo+8oWv1RonmtqDcRd+gfwEv5Rj2y2DDKJrU9KKVSClOF0ZZSENj7Pzoc4N6o4y8gXOT91Q1AIwS9/Twg/nc4tCEMREPg+RuYstlSEXNnFIYeTND+vqPfkfKC/+16RQHQIDAQAB"
  }
  default_ttl = local.default_ttl
}

resource "aws_route53_record" "home" {
  zone_id = module.frigon_app_dns.zone_id
  type    = "A"
  name    = "home"
  records = [local.home_ip]
  ttl     = local.default_ttl
}

# xlang.dev dns

module "xlang_dev_dns" {
  source = "../modules/dns"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain           = local.xlang_domain
  update_registrar = true
  default_ttl      = local.default_ttl
}

// Wait for new NS records to propagate from Amazon Registrar through IANA
// to the TLD nameservers. EnableHostedZoneDNSSEC queries the parent and
// fails with HostedZonePartiallyDelegated until propagation completes.
resource "time_sleep" "dnssec_delegation" {
  depends_on      = [module.xlang_dev_dns]
  create_duration = "300s"
}

module "xlang_dev_dnssec" {
  source = "../modules/dnssec"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  domain  = local.xlang_domain
  zone_id = module.xlang_dev_dns.zone_id

  depends_on = [time_sleep.dnssec_delegation]
}
