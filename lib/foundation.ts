import { Stack, StackProps } from "aws-cdk-lib"
import { Construct } from "constructs"
import * as iam from "aws-cdk-lib/aws-iam"
import * as github from "xehos-cdk-lib/github"
import * as budgets from "aws-cdk-lib/aws-budgets"

export class FoundationStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props)

        new github.OpenIdConnectProvider(this, "oidc-provider")

        const bootstrapPolicy = new iam.ManagedPolicy(this, "bootstrap_cdk", {
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

        const policy = new iam.ManagedPolicy(this, "aws_setup", {
            statements: [
                new iam.PolicyStatement({
                    actions: [
                        "route53:*"
                    ],
                    resources: ["*"]
                })
            ]
        })

        new github.GithubActionRole(this, "github_actions", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "aws-setup"),
            policies: [
                bootstrapPolicy,
                policy
            ]
        })

        const subscriber: budgets.CfnBudget.SubscriberProperty = {
            address: "aws@frigon.app",
            subscriptionType: "EMAIL"
        }

        new budgets.CfnBudget(this, "monthly", {
            budget: {
                budgetType: "COST",
                timeUnit: "MONTHLY",
                budgetName: "Monthly Budget",
                budgetLimit: { amount: 100, unit: "USD" }
            },
            notificationsWithSubscribers: [
                {
                    notification: {
                        notificationType: "ACTUAL",
                        comparisonOperator: "GREATER_THAN",
                        thresholdType: "PERCENTAGE",
                        threshold: 50
                    },
                    subscribers: [subscriber]
                },
                {
                    notification: {
                        notificationType: "ACTUAL",
                        comparisonOperator: "GREATER_THAN",
                        thresholdType: "PERCENTAGE",
                        threshold: 100
                    },
                    subscribers: [subscriber]
                },
                {
                    notification: {
                        notificationType: "FORECASTED",
                        comparisonOperator: "GREATER_THAN",
                        thresholdType: "PERCENTAGE",
                        threshold: 100
                    },
                    subscribers: [subscriber]
                }
            ]
        })
    }
}
