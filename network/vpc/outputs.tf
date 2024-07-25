### Outputs
output "id"             { value = module.vpc.id }
output "name"           { value = module.vpc.name }

output "rt_default"     { value = module.vpc.rt_default }
output "rt_public"      { value = module.vpc.rt_public }
output "rts_private"     { value = aws_route_table.private.*.id }

output "public_subnets" { value = module.vpc.public_subnets }
output "private_subnets" { value = module.private-subnets }
output "isolated_subnets" { value = module.isolated-subnets }
