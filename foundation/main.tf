terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

locals {
  owner = "afrigon"
}

// Resume Role

module "resume_role" {
  source = "../modules/ci-role"

  name = "resume"
  state_bucket = var.state_bucket
  github = {
    owner      = local.owner
    repository = "resume"
  }
}

// Minecraft Role

module "minecraft_role" {
  source = "../modules/ci-role"

  name = "minecraft"
  state_bucket = var.state_bucket
  github = {
    owner      = local.owner
    repository = "minecraft-server"
  }
}

// x-lang Role

module "xlang_role" {
  source = "../modules/ci-role"

  name = "xlang"
  state_bucket = var.state_bucket
  github = {
    owner      = local.owner
    repository = "x-lang"
  }
}

# frigon.app dns

module "frigon_app_dns" {
  source = "../modules/dns"

  domain = "frigon.app"
  is_aws_domains = false
  email_configuration = {
    mxa = "mxa.mailgun.org"
    mxb = "mxb.mailgun.org"
    spf = "v=spf1 include:mailgun.org ~all"
    dkim = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDaHU9ZpyHxZ1fKH2t3czU+OH7vsca9H5evUb1bfKhGuUo+8oWv1RonmtqDcRd+gfwEv5Rj2y2DDKJrU9KKVSClOF0ZZSENj7Pzoc4N6o4y8gXOT91Q1AIwS9/Twg/nc4tCEMREPg+RuYstlSEXNnFIYeTND+vqPfkfKC/+16RQHQIDAQAB"
  }
}

resource "aws_route53_record" "home" {
    zone_id = module.frigon_app_dns.zone_id
    type = "A"
    name = "home"
    records = ["107.171.186.150"]
    ttl = 1800
}

# x-lang.dev dns

module "xlang_dev_dns" {
  source = "../modules/dns"

  domain = "x-lang.dev"
  is_aws_domains = true
}