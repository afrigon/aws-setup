import { Stack, StackProps } from "aws-cdk-lib"
import { Construct } from "constructs"
import * as dns from "xehos-cdk-lib/dns"
import * as r53 from "aws-cdk-lib/aws-route53"

export class FrigonStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props)

        new dns.DNS(this, "DNS", {
            domain: "frigon.app",
            emailConfiguration: {
                mxa: "mxa.mailgun.org",
                mxb: "mxb.mailgun.org",
                spf: "v=spf1 include:mailgun.org ~all",
                dkim: "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDaHU9ZpyHxZ1fKH2t3czU+OH7vsca9H5evUb1bfKhGuUo+8oWv1RonmtqDcRd+gfwEv5Rj2y2DDKJrU9KKVSClOF0ZZSENj7Pzoc4N6o4y8gXOT91Q1AIwS9/Twg/nc4tCEMREPg+RuYstlSEXNnFIYeTND+vqPfkfKC/+16RQHQIDAQAB"
            }
        })

        // Home Lab Subdomain
        const zone = r53.PublicHostedZone.fromLookup(this, "zone", {
            domainName: "frigon.app"
        })

        // new r53.ARecord(this, "A-home", {
        //     zone,
        //     recordName: "home",
        //     target: r53.RecordTarget.fromIpAddresses("107.171.186.150")
        // })
    }
}
