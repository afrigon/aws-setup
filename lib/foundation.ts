import { Stack, StackProps } from "aws-cdk-lib"
import { Construct } from "constructs"
import * as budgets from "aws-cdk-lib/aws-budgets"
import * as github from "xehos-cdk-lib/github"
import { CIRole } from "./constructs/ci-role.ts"

export class FoundationStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props)

        const subscriber: budgets.CfnBudget.SubscriberProperty = {
            address: "aws@frigon.app",
            subscriptionType: "EMAIL"
        }

        new budgets.CfnBudget(this, "Monthly", {
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

        new CIRole(this, "Resume", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "resume"),
            actions: [
                // Route53 - for hosted zone lookup (synth) and DNS records
                "route53:ListHostedZonesByName",
                "route53:ChangeResourceRecordSets",
                // ACM - for certificate creation and DNS validation
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                // S3 - for bucket creation and BucketDeployment (with prune)
                "s3:CreateBucket",
                "s3:PutBucketEncryption",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketVersioning",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                // CloudFront - for distribution and cache invalidation
                "cloudfront:CreateDistribution",
                "cloudfront:UpdateDistribution",
                "cloudfront:GetDistribution",
                "cloudfront:CreateInvalidation",
                // IAM - for CloudFront OAC role and Lambda execution roles
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                // Lambda - for BucketDeployment custom resource handler
                "lambda:CreateFunction",
                "lambda:UpdateFunctionCode",
                "lambda:DeleteFunction",
                "lambda:GetFunction",
                "lambda:InvokeFunction",
                "lambda:AddPermission",
                "lambda:RemovePermission"
            ]
        })
    }
}
