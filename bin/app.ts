import * as cdk from "aws-cdk-lib"
import { CoreStack } from "../lib/core.js"
import { FoundationStack } from "../lib/foundation.js"
import { FrigonStack } from "../lib/frigon.ts"
import { XStack } from "../lib/x.ts"

const app = new cdk.App()

const env = { account: process.env.AWS_ACCOUNT, region: process.env.AWS_REGION }

new CoreStack(app, "Core", { 
    description: "This stack includes resources needed to run the aws-setup CI",
    env
})

new FoundationStack(app, "Foundation", { 
    description: "This stack creates users used on other projects and account wide configurations",
    env
})

new FrigonStack(app, "Frigon", {
    description: "This stack includes resources for the frigon.app domain",
    env
})

new XStack(app, "X", {
    description: "This stack includes resources for the x-lang.dev domain",
    env
})
