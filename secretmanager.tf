/*----------------------------------------------------------------------*/
/* RDS Variables                                                        */
/*----------------------------------------------------------------------*/
resource "aws_secretsmanager_secret" "this" {
  for_each = var.rds_aurora_parameters

  name                    = try(each.value.secret.name, var.rds_aurora_defaults.secret.name, "rds-${local.common_name}-${each.key}")
  description             = try(each.value.secret.description, var.rds_aurora_defaults.secret.description, "Root Secret for rds instance")
  kms_key_id              = try(each.value.secret.kms_key_id, var.rds_aurora_defaults.secret.kms_key_id, null)
  recovery_window_in_days = try(each.value.secret.recovery_window_in_days, var.rds_aurora_defaults.secret.recovery_window_in_days, 30)
  tags                    = local.common_tags
}

resource "aws_secretsmanager_secret_version" "secret_val" {
  for_each = var.rds_aurora_parameters

  secret_id = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode({
    "engine" : "${module.rds_aurora[each.key].cluster_engine_version_actual}",
    "host" : try(each.value.dns_records[""].zone_name, "") != "" ? "${local.common_name}-${each.key}.rds.${each.value.dns_records[""].zone_name}" : "${module.rds_aurora[each.key].cluster_endpoint}",
    "username" : "${module.rds_aurora[each.key].cluster_master_username}",
    "password" : "${try(each.value.master_password, var.rds_aurora_defaults.master_password, random_password.this[each.key].result)}",
    "dbname" : try(module.rds_aurora[each.key].cluster_database_name, ""),
    "port" : "${module.rds_aurora[each.key].cluster_port}",
    "rds_host" : "${module.rds_aurora[each.key].cluster_endpoint}",
    "rds_cluster_writer_host" : "${module.rds_aurora[each.key].cluster_endpoint}",
    "rds_cluster_read_host" : "${module.rds_aurora[each.key].cluster_reader_endpoint}",
    }
  )
}