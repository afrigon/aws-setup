terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

// Terraform State Bucket

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Github Identity Provider

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

// Foundation Role

locals {
  role_name = "foundation"
}

module "foundation_role" {
  source     = "../modules/ci-role"
  depends_on = [aws_iam_openid_connect_provider.github]

  name         = local.role_name
  state_bucket = var.state_bucket
  github       = var.github
  permissions = [
    {
      actions = [
        "iam:ListOpenIDConnectProviders",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      resources = ["*"]
    },
    {
      actions   = ["iam:GetOpenIDConnectProvider"],
      resources = [aws_iam_openid_connect_provider.github.arn]
    }
  ]
}
