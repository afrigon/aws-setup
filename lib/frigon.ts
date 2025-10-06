import { BaseStack, BaseStackProps } from "xehos-cdk-lib"
import { Construct } from "constructs"
import * as dns from "xehos-cdk-lib/dns"

export class FrigonStack extends BaseStack {
    constructor(scope: Construct, id: string, props: BaseStackProps) {
        super(scope, id, props)

        new dns.DNS(this, this.context.identifier("dns"), {
            domain: "frigon.app",
            emailConfiguration: {
                mxa: "mxa.mailgun.org",
                mxb: "mxb.mailgun.org",
                spf: "v=spf1 include:mailgun.org ~all",
                dkim: "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDaHU9ZpyHxZ1fKH2t3czU+OH7vsca9H5evUb1bfKhGuUo+8oWv1RonmtqDcRd+gfwEv5Rj2y2DDKJrU9KKVSClOF0ZZSENj7Pzoc4N6o4y8gXOT91Q1AIwS9/Twg/nc4tCEMREPg+RuYstlSEXNnFIYeTND+vqPfkfKC/+16RQHQIDAQAB"
            }
        })
    }
}
