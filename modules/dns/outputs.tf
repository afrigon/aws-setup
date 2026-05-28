output "zone_id" {
    value = aws_route53_zone.zone.zone_id
}

output "name_servers" {
    value = aws_route53_zone.zone.name_servers
}

output "ds" {
    description = "DS record that needs to be configured with any external domain registrar"
    value = format(
        "%s %s %s %s",
        aws_route53_key_signing_key.signing_key.key_tag,
        aws_route53_key_signing_key.signing_key.signing_algorithm_mnemonic,
        aws_route53_key_signing_key.signing_key.digest_algorithm_mnemonic,
        aws_route53_key_signing_key.signing_key.digest_value
    )
}