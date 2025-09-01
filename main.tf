module "rds_aurora" {
  for_each = var.rds_aurora_parameters
  source   = "terraform-aws-modules/rds-aurora/aws"
  version  = "9.15.0"


  create = true
  name   = try(each.value.name, var.rds_aurora_defaults.name, "${local.common_name}-${each.key}")

  /*---------------------------*/
  /* DB Subnet Group           */
  /*---------------------------*/
  create_db_subnet_group = try(each.value.create_db_subnet_group, var.rds_aurora_defaults.create_db_subnet_group, true)
  db_subnet_group_name   = try(each.value.db_subnet_group_name, var.rds_aurora_defaults.db_subnet_group_name, "${local.common_name}-${each.key}-sg")
  subnets                = try(each.value.subnets, var.rds_aurora_defaults.subnets, data.aws_subnets.this[each.key].ids)

  /*---------------------------*/
  /* Cluster                   */
  /*---------------------------*/
  cluster_use_name_prefix                     = try(each.value.cluster_use_name_prefix, var.rds_aurora_defaults.cluster_use_name_prefix, false)
  is_primary_cluster                          = try(each.value.is_primary_cluster, var.rds_aurora_defaults.is_primary_cluster, true)
  allocated_storage                           = try(each.value.allocated_storage, var.rds_aurora_defaults.allocated_storage, null)
  allow_major_version_upgrade                 = try(each.value.allow_major_version_upgrade, var.rds_aurora_defaults.allow_major_version_upgrade, false)
  apply_immediately                           = try(each.value.apply_immediately, var.rds_aurora_defaults.apply_immediately, false)
  availability_zones                          = try(each.value.availability_zones, var.rds_aurora_defaults.availability_zones, null)
  backup_retention_period                     = try(each.value.backup_retention_period, var.rds_aurora_defaults.backup_retention_period, null)
  backtrack_window                            = try(each.value.backtrack_window, var.rds_aurora_defaults.backtrack_window, null)
  cluster_members                             = try(each.value.cluster_members, var.rds_aurora_defaults.cluster_members, null)
  copy_tags_to_snapshot                       = try(each.value.copy_tags_to_snapshot, var.rds_aurora_defaults.copy_tags_to_snapshot, null)
  database_name                               = try(each.value.database_name, var.rds_aurora_defaults.database_name, null)
  db_cluster_instance_class                   = try(each.value.db_cluster_instance_class, var.rds_aurora_defaults.db_cluster_instance_class, null)
  db_cluster_db_instance_parameter_group_name = try(each.value.db_cluster_db_instance_parameter_group_name, var.rds_aurora_defaults.db_cluster_db_instance_parameter_group_name, "")
  delete_automated_backups                    = try(each.value.delete_automated_backups, var.rds_aurora_defaults.delete_automated_backups, null)
  deletion_protection                         = try(each.value.deletion_protection, var.rds_aurora_defaults.deletion_protection, true)
  enable_global_write_forwarding              = try(each.value.enable_global_write_forwarding, var.rds_aurora_defaults.enable_global_write_forwarding, null)
  enabled_cloudwatch_logs_exports             = try(each.value.enabled_cloudwatch_logs_exports, var.rds_aurora_defaults.enabled_cloudwatch_logs_exports, [])
  enable_http_endpoint                        = try(each.value.enable_http_endpoint, var.rds_aurora_defaults.enable_http_endpoint, null)
  engine                                      = try(each.value.engine, var.rds_aurora_defaults.engine, null)
  engine_mode                                 = try(each.value.engine_mode, var.rds_aurora_defaults.engine_mode, "provisioned")
  engine_version                              = try(each.value.engine_version, var.rds_aurora_defaults.engine_version, null)
  final_snapshot_identifier                   = try(each.value.final_snapshot_identifier, var.rds_aurora_defaults.final_snapshot_identifier, null)
  global_cluster_identifier                   = try(each.value.global_cluster_identifier, var.rds_aurora_defaults.global_cluster_identifier, null)
  iam_database_authentication_enabled         = try(each.value.iam_database_authentication_enabled, var.rds_aurora_defaults.iam_database_authentication_enabled, false) // autentica por iam role
  iops                                        = try(each.value.iops, var.rds_aurora_defaults.iops, null)
  kms_key_id                                  = try(each.value.kms_key_id, var.rds_aurora_defaults.kms_key_id, null)
  network_type                                = try(each.value.network_type, var.rds_aurora_defaults.network_type, null) // IPV4 or DUAL
  port                                        = try(each.value.port, var.rds_aurora_defaults.port, 3306)
  preferred_backup_window                     = try(each.value.preferred_backup_window, var.rds_aurora_defaults.preferred_backup_window, "02:00-03:00")
  preferred_maintenance_window                = try(each.value.preferred_maintenance_window, var.rds_aurora_defaults.preferred_maintenance_window, "sun:05:00-sun:06:00")
  replication_source_identifier               = try(each.value.replication_source_identifier, var.rds_aurora_defaults.replication_source_identifier, null)
  restore_to_point_in_time                    = try(each.value.restore_to_point_in_time, var.rds_aurora_defaults.restore_to_point_in_time, {})
  scaling_configuration                       = try(each.value.scaling_configuration, var.rds_aurora_defaults.scaling_configuration, {})                           // only with engine_mode on serverless
  serverlessv2_scaling_configuration          = try(each.value.serverlessv2_scaling_configuration, var.rds_aurora_defaults.serverlessv2_scaling_configuration, {}) // only with engine_mode on provisioned
  skip_final_snapshot                         = try(each.value.skip_final_snapshot, var.rds_aurora_defaults.skip_final_snapshot, false)
  snapshot_identifier                         = try(each.value.snapshot_identifier, var.rds_aurora_defaults.snapshot_identifier, null)
  source_region                               = try(each.value.source_region, var.rds_aurora_defaults.source_region, null)
  storage_encrypted                           = try(each.value.storage_encrypted, var.rds_aurora_defaults.storage_encrypted, true) // necesita kms id
  storage_type                                = try(each.value.storage_type, var.rds_aurora_defaults.storage_type, "aurora")
  cluster_tags                                = local.common_tags
  vpc_security_group_ids                      = try(each.value.vpc_security_group_ids, var.rds_aurora_defaults.vpc_security_group_ids, [module.security_group_rds[each.key].security_group_id])
  cluster_timeouts                            = try(each.value.cluster_timeouts, var.rds_aurora_defaults.cluster_timeouts, {})
  enable_local_write_forwarding               = try(each.value.enable_local_write_forwarding, var.rds_aurora_defaults.enable_local_write_forwarding, null)
  cluster_ca_cert_identifier                  = try(each.value.cluster_ca_cert_identifier, var.rds_aurora_defaults.cluster_ca_cert_identifier, null)
  engine_lifecycle_support                    = try(each.value.engine_lifecycle_support, var.rds_aurora_defaults.engine_lifecycle_support, null)
  cluster_monitoring_interval                 = try(each.value.cluster_monitoring_interval, var.rds_aurora_defaults.cluster_monitoring_interval, 0)
  cluster_scalability_type                    = try(each.value.cluster_scalability_type, var.rds_aurora_defaults.cluster_scalability_type, null)
  database_insights_mode                      = try(each.value.database_insights_mode, var.rds_aurora_defaults.database_insights_mode, null)

  /*---------------------------*/
  /* Instances                 */
  /*---------------------------*/
  instances                             = try(each.value.instances, var.rds_aurora_defaults.instances, {})
  endpoints                             = try(each.value.endpoints, var.rds_aurora_defaults.endpoints, {})
  auto_minor_version_upgrade            = try(each.value.auto_minor_version_upgrade, var.rds_aurora_defaults.auto_minor_version_upgrade, true)
  ca_cert_identifier                    = try(each.value.ca_cert_identifier, var.rds_aurora_defaults.ca_cert_identifier, null)
  instances_use_identifier_prefix       = try(each.value.instances_use_identifier_prefix, var.rds_aurora_defaults.instances_use_identifier_prefix, false)
  instance_class                        = try(each.value.instance_class, var.rds_aurora_defaults.instance_class, "")
  monitoring_interval                   = try(each.value.monitoring_interval, var.rds_aurora_defaults.monitoring_interval, 0)
  performance_insights_enabled          = try(each.value.performance_insights_enabled, var.rds_aurora_defaults.performance_insights_enabled, null)
  performance_insights_kms_key_id       = try(each.value.performance_insights_kms_key_id, var.rds_aurora_defaults.performance_insights_kms_key_id, null)
  performance_insights_retention_period = try(each.value.performance_insights_retention_period, var.rds_aurora_defaults.performance_insights_retention_period, null)
  publicly_accessible                   = try(each.value.publicly_accessible, var.rds_aurora_defaults.publicly_accessible, false)
  instance_timeouts                     = try(each.value.instance_timeouts, var.rds_aurora_defaults.instance_timeouts, {})

  /*---------------------------*/
  /* Managed Secret Rotation   */
  /*---------------------------*/
  manage_master_user_password                       = false
  master_user_secret_kms_key_id                     = try(each.value.master_user_secret_kms_key_id, var.rds_aurora_defaults.master_user_secret_kms_key_id, null)
  master_username                                   = try(each.value.master_username, var.rds_aurora_defaults.master_username, "root")
  master_password                                   = try(each.value.master_password, var.rds_aurora_defaults.master_password, random_password.this[each.key].result)
  manage_master_user_password_rotation              = try(each.value.manage_master_user_password_rotation, var.rds_aurora_parameters.manage_master_user_password_rotation, false)
  master_user_password_rotate_immediately           = try(each.value.master_user_password_rotate_immediately, var.rds_aurora_defaults.master_user_password_rotate_immediately, null)
  master_user_password_rotation_duration            = try(each.value.master_user_password_rotation_duration, var.rds_aurora_defaults.master_user_password_rotation_duration, null)
  master_user_password_rotation_schedule_expression = try(each.value.master_user_password_rotation_schedule_expression, var.rds_aurora_defaults.master_user_password_rotation_schedule_expression, null)

  /*---------------------------*/
  /* Cluster Parameter Group   */
  /*---------------------------*/
  create_db_cluster_parameter_group      = try(each.value.create_db_cluster_parameter_group, var.rds_aurora_defaults.create_db_cluster_parameter_group, true)
  db_cluster_parameter_group_name        = try(each.value.db_cluster_parameter_group_name, var.rds_aurora_defaults.db_cluster_parameter_group_name, "${local.common_name}-${each.key}-cpg")
  db_cluster_parameter_group_family      = try(each.value.parameter_group_family, each.value.db_cluster_parameter_group_family, var.rds_aurora_defaults.db_cluster_parameter_group_family, null)
  db_cluster_parameter_group_description = try(each.value.db_cluster_parameter_group_description, var.rds_aurora_defaults.db_cluster_parameter_group_description, "Cluster parameter group for ${local.common_name}-${each.key}")
  db_cluster_parameter_group_parameters  = try(each.value.db_cluster_parameter_group_parameters, var.rds_aurora_defaults.db_cluster_parameter_group_parameters, [])

  /*---------------------------*/
  /* Parameter Group           */
  /*---------------------------*/
  create_db_parameter_group      = try(each.value.create_db_parameter_group, var.rds_aurora_defaults.create_db_parameter_group, true)
  db_parameter_group_name        = try(each.value.db_parameter_group_name, var.rds_aurora_defaults.db_parameter_group_name, "${local.common_name}-${each.key}-pg")
  db_parameter_group_family      = try(each.value.parameter_group_family, each.value.db_parameter_group_family, var.rds_aurora_defaults.db_parameter_group_family, null)
  db_parameter_group_description = try(each.value.db_parameter_group_description, var.rds_aurora_defaults.db_parameter_group_description, "Parameter group for ${local.common_name}-${each.key}")
  db_parameter_group_parameters  = try(each.value.db_parameter_group_parameters, var.rds_aurora_defaults.db_parameter_group_parameters, [])

  /*---------------------------*/
  /* Security Group            */
  /*---------------------------*/
  create_security_group          = try(each.value.create_security_group, var.rds_aurora_defaults.create_security_group, false)
  security_group_name            = try(each.value.security_group_name, var.rds_aurora_defaults.security_group_name, "${local.common_name}-rds-${each.key}")
  security_group_use_name_prefix = try(each.value.security_group_use_name_prefix, var.rds_aurora_defaults.security_group_use_name_prefix, false)
  security_group_description     = try(each.value.security_group_description, var.rds_aurora_defaults.security_group_description, "Security Group for ${local.common_name}-${each.key}")
  vpc_id                         = try(each.value.vpc_id, var.rds_aurora_defaults.vpc_id, data.aws_vpc.this[each.key].id)
  security_group_rules           = try(each.value.security_group_rules, var.rds_aurora_defaults.security_group_rules, {})

  /*---z-----------------------*/
  /* CloudWatch Log Group      */
  /*---------------------------*/
  create_cloudwatch_log_group            = try(each.value.create_cloudwatch_log_group, var.rds_aurora_defaults.create_cloudwatch_log_group, true)
  cloudwatch_log_group_retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, var.rds_aurora_defaults.cloudwatch_log_group_retention_in_days, 7)
  cloudwatch_log_group_kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, var.rds_aurora_defaults.cloudwatch_log_group_kms_key_id, null)
  cloudwatch_log_group_skip_destroy      = try(each.value.cloudwatch_log_group_skip_destroy, var.rds_aurora_defaults.cloudwatch_log_group_skip_destroy, null)
  cloudwatch_log_group_class             = try(each.value.cloudwatch_log_group_class, var.rds_aurora_defaults.cloudwatch_log_group_class, null)
  cloudwatch_log_group_tags              = try(each.value.cloudwatch_log_group_tags, var.rds_aurora_defaults.cloudwatch_log_group_tags, {})

  /*---------------------------*/
  /* Cluster Activity Stream   */
  /*---------------------------*/
  create_db_cluster_activity_stream     = try(each.value.create_db_cluster_activity_stream, var.rds_aurora_defaults.create_db_cluster_activity_stream, false)
  db_cluster_activity_stream_kms_key_id = try(each.value.db_cluster_activity_stream_kms_key_id, var.rds_aurora_defaults.db_cluster_activity_stream_kms_key_id, "")
  db_cluster_activity_stream_mode       = try(each.value.db_cluster_activity_stream_mode, var.rds_aurora_defaults.db_cluster_activity_stream_mode, "async")

  /*---------------------------*/
  /* Enhanced Monitoring       */
  /*---------------------------*/
  create_monitoring_role         = try(each.value.create_monitoring_role, var.rds_aurora_defaults.create_monitoring_role, true)
  monitoring_role_arn            = try(each.value.monitoring_role_arn, var.rds_aurora_defaults.monitoring_role_arn, null)
  iam_role_name                  = try(each.value.iam_role_name, var.rds_aurora_defaults.iam_role_name, "${local.common_name}-${each.key}-role")
  iam_role_use_name_prefix       = try(each.value.iam_role_use_name_prefix, var.rds_aurora_defaults.iam_role_use_name_prefix, false)
  iam_role_description           = try(each.value.iam_role_description, var.rds_aurora_defaults.iam_role_description, null)
  iam_role_path                  = try(each.value.iam_role_path, var.rds_aurora_defaults.iam_role_path, null)
  iam_role_managed_policy_arns   = try(each.value.iam_role_managed_policy_arns, var.rds_aurora_defaults.iam_role_managed_policy_arns, null)
  iam_role_permissions_boundary  = try(each.value.iam_role_permissions_boundary, var.rds_aurora_defaults.iam_role_permissions_boundary, null)
  iam_role_force_detach_policies = try(each.value.iam_role_force_detach_policies, var.rds_aurora_defaults.iam_role_force_detach_policies, null)
  iam_role_max_session_duration  = try(each.value.iam_role_max_session_duration, var.rds_aurora_defaults.iam_role_max_session_duration, null)

  /*---------------------------*/
  /* Cluster Performance       */
  /*---------------------------*/
  cluster_performance_insights_enabled          = try(each.value.cluster_performance_insights_enabled, var.rds_aurora_defaults.cluster_performance_insights_enabled, null)
  cluster_performance_insights_kms_key_id       = try(each.value.cluster_performance_insights_kms_key_id, var.rds_aurora_defaults.cluster_performance_insights_kms_key_id, null)
  cluster_performance_insights_retention_period = try(each.value.cluster_performance_insights_retention_period, var.rds_aurora_defaults.cluster_performance_insights_retention_period, null)

  /*---------------------------*/
  /* Shard Group               */
  /*---------------------------*/
  create_shard_group        = try(each.value.create_shard_group, var.rds_aurora_defaults.create_shard_group, false)
  compute_redundancy        = try(each.value.compute_redundancy, var.rds_aurora_defaults.compute_redundancy, null)
  db_shard_group_identifier = try(each.value.db_shard_group_identifier, var.rds_aurora_defaults.db_shard_group_identifier, null)
  max_acu                   = try(each.value.max_acu, var.rds_aurora_defaults.max_acu, null)
  min_acu                   = try(each.value.min_acu, var.rds_aurora_defaults.min_acu, null)
  shard_group_tags          = try(each.value.shard_group_tags, var.rds_aurora_defaults.shard_group_tags, {})
  shard_group_timeouts      = try(each.value.shard_group_timeouts, var.rds_aurora_defaults.shard_group_timeouts, {})

  tags = local.common_tags
}