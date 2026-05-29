output "domain" {
  value = var.domain
}

output "signing_algorithm" {
  value = aws_route53_key_signing_key.signing_key.signing_algorithm_type
}

output "flags" {
  value = aws_route53_key_signing_key.signing_key.flag
}

output "public_key" {
  value = aws_route53_key_signing_key.signing_key.public_key
}

output "dnssec_key_id" {
  value       = "${aws_route53_key_signing_key.signing_key.flag}-3-${aws_route53_key_signing_key.signing_key.signing_algorithm_type}-${aws_route53_key_signing_key.signing_key.public_key}"
  description = "DnssecKey.Id format used by route53domains (flags-protocol-algorithm-publickey)"
}

output "associate_command" {
  description = "Run once after apply to register the DS record at the parent registrar."
  value = join(" ", [
    "aws route53domains associate-delegation-signer-to-domain",
    "--region us-east-1",
    "--domain-name ${var.domain}",
    "--signing-attributes Algorithm=${aws_route53_key_signing_key.signing_key.signing_algorithm_type},Flags=${aws_route53_key_signing_key.signing_key.flag},PublicKey=${aws_route53_key_signing_key.signing_key.public_key}",
  ])
}

output "disassociate_command" {
  description = "Run before terraform destroy, then wait ~5min for TLD propagation."
  value = join(" ", [
    "aws route53domains disassociate-delegation-signer-from-domain",
    "--region us-east-1",
    "--domain-name ${var.domain}",
    "--id '${aws_route53_key_signing_key.signing_key.flag}-3-${aws_route53_key_signing_key.signing_key.signing_algorithm_type}-${aws_route53_key_signing_key.signing_key.public_key}'",
  ])
}
