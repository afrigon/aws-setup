import { Construct } from "constructs"
import * as iam from "aws-cdk-lib/aws-iam"
import * as github from "xehos-cdk-lib/github"

export interface CIRoleProps {
    repository: github.GithubRepositoryIdentifier,
    actions?: string[]
}

export class CIRole extends Construct {
    constructor(scope: Construct, id: string, props: CIRoleProps) {
        super(scope, id)

        const bootstrapPolicy = iam.ManagedPolicy.fromManagedPolicyName(this, "BootstrapCDK", "Foundation-BootstrapCDK") as iam.ManagedPolicy
        const policies = [bootstrapPolicy]

        if (props.actions && props.actions.length) {
            const policy = new iam.ManagedPolicy(this, `${props.repository.awsIdentifier()}Policy`, {
                statements: [
                    new iam.PolicyStatement({
                        actions: props.actions,
                        resources: ["*"]
                    })
                ]
            })

            policies.push(policy)
        }

        new github.GithubActionRole(this, `${props.repository.awsIdentifier()}Role`, {
            repository: props.repository,
            policies
        })
    }
}
