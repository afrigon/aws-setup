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
  resume = "resume"
  minecraft = "minecraft"
  xlang = "x-lang"
}

// Resume Role

module "resume_role" {
  source = "../modules/ci-role"

  name = local.resume
  state_bucket = var.state_bucket
  github = {
    owner      = local.owner
    repository = local.resume
  }
}
