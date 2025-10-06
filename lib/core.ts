import { Stack, StackProps } from "aws-cdk-lib"
import { Construct } from "constructs"
import * as iam from "aws-cdk-lib/aws-iam"
import * as github from "xehos-cdk-lib/github"
import { CIRole } from "./constructs/ci-role.ts"

export class CoreStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props)

        new github.GithubOpenIdConnectProvider(this, "Provider")

        new iam.ManagedPolicy(this, "BootstrapCDK", {
            managedPolicyName: "BootstrapCDK",
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

        new CIRole(this, "AWSSetup", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "aws-setup"),
            actions: [
                "route53:*"
            ]
        })
    }
}
