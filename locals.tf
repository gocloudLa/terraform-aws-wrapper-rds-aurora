locals {
  rds_vpc_security_group_ids = {
    for key, value in var.rds_aurora_parameters :
    key => concat(
      (
        lookup(value, "security_group_create", true) ? [module.security_group_rds[key].security_group_id] : []
      ),
      try(coalescelist(
        lookup(value, "vpc_security_group_ids", []),
        lookup(var.rds_aurora_defaults, "vpc_security_group_ids", [])
      ), [])
    )
  }

  rds_cluster_parameter_group = {
    for key, value in var.rds_aurora_parameters :
    key => {
      name            = "${local.common_name}-${key}-cpg"
      use_name_prefix = true
      family          = try(value.parameter_group_family, var.rds_aurora_defaults.parameter_group_family, "${try(value.engine, var.rds_aurora_defaults.engine)}${try(value.engine_version, var.rds_aurora_defaults.engine_version)}")
      description     = "Cluster parameter group for ${local.common_name}-${key}"
      parameters      = try(value.db_cluster_parameter_group_parameters, var.rds_aurora_defaults.db_cluster_parameter_group_parameters, [])
    }
  }

  rds_db_parameter_group = {
    for key, value in var.rds_aurora_parameters :
    key => {
      name            = "${local.common_name}-${key}-pg"
      use_name_prefix = true
      family          = try(value.parameter_group_family, var.rds_aurora_defaults.parameter_group_family, "${try(value.engine, var.rds_aurora_defaults.engine)}${try(value.engine_version, var.rds_aurora_defaults.engine_version)}")
      description     = "Parameter group for ${local.common_name}-${key}"
      parameters      = try(value.db_parameter_group_parameters, var.rds_aurora_defaults.db_parameter_group_parameters, [])
    }
  }
}