import { BaseStack, BaseStackProps } from "xehos-cdk-lib"
import { Construct } from "constructs"
import * as iam from "aws-cdk-lib/aws-iam"
import * as github from "xehos-cdk-lib/github"

export class FoundationStack extends BaseStack {
    constructor(scope: Construct, id: string, props: BaseStackProps) {
        super(scope, id, props)

        new github.OpenIdConnectProvider(this, this.context.identifier("github", "oidc-provider"))

        const bootstrapPolicy = new iam.ManagedPolicy(this, this.context.identifier("bootstrap-cdk"), {
            description: "base policy required to bootstrap cdk",
            statements: [
                new iam.PolicyStatement({
                    actions: [
                        "cloudformation:*",
                        "ecr:*",
                        "ssm:*",
                        "s3:*",
                        "iam:*"
                    ],
                    resources: ["*"]
                })
            ]
        })

        const policy = new iam.ManagedPolicy(this, this.context.identifier("aws-setup"), {
            statements: [
                new iam.PolicyStatement({
                    actions: [
                        "route53:*"
                    ],
                    resources: ["*"]
                })
            ]
        })

        new github.GithubActionRole(this, this.context.identifier("github-role"), {
            repository: new github.GithubRepositoryIdentifier("afrigon", "aws-setup"),
            policies: [
                bootstrapPolicy,
                policy
            ]
        })
    }
}
