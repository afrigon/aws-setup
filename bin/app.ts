import * as cdk from "aws-cdk-lib"
import { FoundationStack } from "../lib/foundation.js"
import { FrigonStack } from "../lib/frigon.ts"

const app = new cdk.App()

new FoundationStack(app, "Foundation")
new FrigonStack(app, "Frigon")
