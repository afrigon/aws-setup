output "zone_id" {
    value = aws_route53_zone.zone.zone_id
}

output "name_servers_1" {
    value = aws_route53_zone.zone.name_servers[0]
}

output "name_servers_2" {
    value = aws_route53_zone.zone.name_servers[1]
}

output "name_servers_3" {
    value = aws_route53_zone.zone.name_servers[2]
}

output "name_servers_4" {
    value = aws_route53_zone.zone.name_servers[3]
}