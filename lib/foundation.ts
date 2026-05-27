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
                "route53:ListHostedZonesByName",
                "route53:ChangeResourceRecordSets",
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "s3:CreateBucket",
                "s3:PutBucketEncryption",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketVersioning",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "cloudfront:CreateDistribution",
                "cloudfront:UpdateDistribution",
                "cloudfront:GetDistribution",
                "cloudfront:CreateInvalidation",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "lambda:CreateFunction",
                "lambda:UpdateFunctionCode",
                "lambda:DeleteFunction",
                "lambda:GetFunction",
                "lambda:InvokeFunction",
                "lambda:AddPermission",
                "lambda:RemovePermission"
            ]
        })

        new CIRole(this, "Minecraft", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "minecraft-server"),
            actions: [
                "route53:ListHostedZonesByName",
                "route53:ChangeResourceRecordSets",
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "s3:*",
                "ec2:*"
            ]
        })

        new CIRole(this, "x-lang", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "x-lang"),
            actions: [
                "route53:ListHostedZonesByName",
                "route53:ChangeResourceRecordSets",
                "acm:RequestCertificate",
                "acm:DescribeCertificate"
            ]
        })
    }
}
