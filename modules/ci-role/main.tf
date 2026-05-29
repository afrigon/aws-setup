data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_s3_bucket" "state_bucket" {
  bucket = var.state_bucket
}

resource "aws_iam_role" "role" {
  name = "terraform-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github.owner}/${var.github.repository}:ref:refs/tags/*"
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

locals {
  default_permissions = [
    {
      actions   = ["s3:ListBucket"],
      resources = [data.aws_s3_bucket.state_bucket.arn]
    },
    {
      actions   = ["s3:GetObject", "s3:PutObject"],
      resources = ["${data.aws_s3_bucket.state_bucket.arn}/${var.name}.tfstate"]
    },
    {
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      resources = ["${data.aws_s3_bucket.state_bucket.arn}/${var.name}.tfstate.tflock"]
    }
  ]
}

resource "aws_iam_role_policy" "default_policy" {
  count = length(local.default_permissions) > 0 ? 1 : 0
  role  = aws_iam_role.role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [for p in local.default_permissions : {
      Effect   = "Allow"
      Action   = p.actions
      Resource = p.resources
    }]
  })
}

resource "aws_iam_role_policy" "inline-policy" {
  count = length(var.permissions) > 0 ? 1 : 0
  role  = aws_iam_role.role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [for p in var.permissions : {
      Effect   = p.effect
      Action   = p.actions
      Resource = p.resources
    }]
  })
}
