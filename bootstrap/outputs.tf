output "state_bucket" {
    value = aws_s3_bucket.terraform_state.id
}

output "github_oidc_provider" {
    value = aws_iam_openid_connect_provider.github.arn
}

output "foundation_role" {
    value = module.foundation_role.aws_role
}
