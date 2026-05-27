import { Stack, StackProps } from "aws-cdk-lib"
import { Construct } from "constructs"
import * as dns from "xehos-cdk-lib/dns"

export class XStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props)

        new dns.DNS(this, "DNS", {
            domain: "x-lang.dev"
        })
    }
}
