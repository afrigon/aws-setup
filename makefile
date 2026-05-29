.PHONY: bootstrap

export AWS_REGION := us-east-1

bootstrap:
	@aws sts get-caller-identity >/dev/null 2>&1 || \
		{ echo "aws cli not authenticated"; exit 1; }
	@aws s3api head-bucket --bucket terraform-xehos 2>/dev/null || \
		{ echo "the bucket must be created manually: s3://terraform-xehos does not exist"; exit 1; }

	terraform -chdir=./bootstrap init
	terraform -chdir=./bootstrap apply
