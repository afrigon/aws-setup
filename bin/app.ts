import * as cdk from "aws-cdk-lib"
import { FoundationStack } from "../lib/foundation.js"
import { ApplicationContext } from "xehos-cdk-lib"
import { FrigonStack } from "../lib/frigon.ts"

const app = new cdk.App()

const foundationContext = new ApplicationContext("foundation")
const frigonContext = new ApplicationContext("frigon")

new FoundationStack(app, foundationContext.identifier("stack"), { context: foundationContext })
new FrigonStack(app, frigonContext.identifier("stack"), { context: frigonContext })
