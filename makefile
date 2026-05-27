.PHONY: bootstrap

export TF_VAR_state_bucket := terraform-xehos
export AWS_REGION          := us-east-1

bootstrap: export TF_VAR_name := bootstrap
bootstrap:
	@aws sts get-caller-identity >/dev/null 2>&1 || \
		{ echo "aws cli not authenticated"; exit 1; }
	@aws s3api head-bucket --bucket $(TF_VAR_state_bucket) 2>/dev/null || \
		{ echo "the bucket must be created manually: s3://$(TF_VAR_state_bucket) does not exist"; exit 1; }

	terraform -chdir=./bootstrap init \
                -backend-config="bucket=$(TF_VAR_state_bucket)" \
                -backend-config="key=$(TF_VAR_name).tfstate" \
				-backend-config="region=$(AWS_REGION)"

	terraform -chdir=./bootstrap apply
