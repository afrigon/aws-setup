// Roles

output "role_resume" {
  value = module.resume_role.aws_role
}

output "role_minecraft" {
  value = module.minecraft_role.aws_role
}

output "role_xlang" {
  value = module.xlang_role.aws_role
}

// frigon DNS

output "name_servers_frigon_app" {
  value = module.frigon_app_dns.name_servers
}

// xlang DNS

output "name_servers_xlang_dev" {
  value = module.xlang_dev_dns.name_servers
}

// xlang DNSSEC — DS record at the registrar must be associated manually.
// See modules/dnssec/main.tf for the reason. Run the associate command
// once after apply; run the disassociate command before destroy.

output "dnssec_xlang_dev_associate_command" {
  value = module.xlang_dev_dnssec.associate_command
}

output "dnssec_xlang_dev_disassociate_command" {
  value = module.xlang_dev_dnssec.disassociate_command
}

output "dnssec_xlang_dev_signing_attributes" {
  value = {
    algorithm  = module.xlang_dev_dnssec.signing_algorithm
    flags      = module.xlang_dev_dnssec.flags
    public_key = module.xlang_dev_dnssec.public_key
  }
}
