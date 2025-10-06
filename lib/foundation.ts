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

        new CIRole(this, "ResumeCIRole", {
            repository: new github.GithubRepositoryIdentifier("afrigon", "resume"),
            actions: []
        })
    }
}
