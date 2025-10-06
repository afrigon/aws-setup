import { Stack, StackProps } from "aws-cdk-lib"
import { Construct } from "constructs"
import * as iam from "aws-cdk-lib/aws-iam"
import * as github from "xehos-cdk-lib/github"

export class CoreStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props)

        new github.GithubOpenIdConnectProvider(this, "Provider")

        const bootstrapPolicy = new iam.ManagedPolicy(this, "BootstrapCDK", {
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

        const policy = new iam.ManagedPolicy(this, "AWSSetup", {
            statements: [
                new iam.PolicyStatement({
                    actions: [
                        "route53:*"
                    ],
                    resources: ["*"]
                })
            ]
        })

        new github.GithubActionRole(this, "AwsSetupRole", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "aws-setup"),
            policies: [
                bootstrapPolicy,
                policy
            ]
        })
    }
}
