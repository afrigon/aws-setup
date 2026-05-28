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

output "frigon_name_servers_1" {
    value = module.frigon_app_dns.name_servers_1
}

output "frigon_name_servers_2" {
    value = module.frigon_app_dns.name_servers_2
}

output "frigon_name_servers_3" {
    value = module.frigon_app_dns.name_servers_3
}

output "frigon_name_servers_4" {
    value = module.frigon_app_dns.name_servers_4
}

// x-lang DNS

output "xlang_name_servers_1" {
    value = module.xlang_dev_dns.name_servers_1
}

output "xlang_name_servers_2" {
    value = module.xlang_dev_dns.name_servers_2
}

output "xlang_name_servers_3" {
    value = module.xlang_dev_dns.name_servers_3
}

output "xlang_name_servers_4" {
    value = module.xlang_dev_dns.name_servers_4
}
