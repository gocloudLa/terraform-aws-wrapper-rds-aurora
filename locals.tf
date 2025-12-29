locals {
  rds_vpc_security_group_ids = concat(
    (
      lookup(each.value, "security_group_create", true) ? [module.security_group_rds[each.key].security_group_id] : []
    ),
    lookup(each.value, "vpc_security_group_ids", []),
    lookup(var.rds_aurora_defaults, "vpc_security_group_ids", [])
  )
}
