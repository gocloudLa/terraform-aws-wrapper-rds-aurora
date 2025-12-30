locals {
  rds_vpc_security_group_ids = {
    for key, value in var.rds_aurora_parameters :
    key => concat(
      (
        lookup(value, "security_group_create", true) ? [module.security_group_rds[key].security_group_id] : []
      ),
      lookup(value, "vpc_security_group_ids", []),
      lookup(var.rds_aurora_defaults, "vpc_security_group_ids", [])
    )
  }
}