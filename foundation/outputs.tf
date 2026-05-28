// Roles

output "resume_role" {
    value = module.resume_role.aws_role
}

output "minecraft_role" {
    value = module.minecraft_role.aws_role
}

output "xlang_role" {
    value = module.xlang_role.aws_role
}

// frigon DNS

output "frigon_name_servers" {
    value = module.frigon_app_dns.name_servers
}

// x-lang DNS

output "xlang_name_servers" {
    value = module.xlang_dev_dns.name_servers
}
