module "rds_aurora" {
  for_each = var.rds_aurora_parameters
  source   = "terraform-aws-modules/rds-aurora/aws"
  version = "10.2.0"


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
  cluster_use_name_prefix                  = try(each.value.cluster_use_name_prefix, var.rds_aurora_defaults.cluster_use_name_prefix, false)
  is_primary_cluster                       = try(each.value.is_primary_cluster, var.rds_aurora_defaults.is_primary_cluster, true)
  allocated_storage                        = try(each.value.allocated_storage, var.rds_aurora_defaults.allocated_storage, null)
  allow_major_version_upgrade              = try(each.value.allow_major_version_upgrade, var.rds_aurora_defaults.allow_major_version_upgrade, false)
  apply_immediately                        = try(each.value.apply_immediately, var.rds_aurora_defaults.apply_immediately, false)
  autoscaling_enabled                      = try(each.value.autoscaling_enabled, var.rds_aurora_defaults.autoscaling_enabled, false)
  autoscaling_max_capacity                 = try(each.value.autoscaling_max_capacity, var.rds_aurora_defaults.autoscaling_max_capacity, 2)
  autoscaling_min_capacity                 = try(each.value.autoscaling_min_capacity, var.rds_aurora_defaults.autoscaling_min_capacity, 0)
  autoscaling_policy_name                  = try(each.value.autoscaling_policy_name, var.rds_aurora_defaults.autoscaling_policy_name, "target-metric")
  autoscaling_scale_in_cooldown            = try(each.value.autoscaling_scale_in_cooldown, var.rds_aurora_defaults.autoscaling_scale_in_cooldown, 300)
  autoscaling_scale_out_cooldown           = try(each.value.autoscaling_scale_out_cooldown, var.rds_aurora_defaults.autoscaling_scale_out_cooldown, 300)
  autoscaling_target_connections           = try(each.value.autoscaling_target_connections, var.rds_aurora_defaults.autoscaling_target_connections, 700)
  autoscaling_target_cpu                   = try(each.value.autoscaling_target_cpu, var.rds_aurora_defaults.autoscaling_target_cpu, 70)
  availability_zones                       = try(each.value.availability_zones, var.rds_aurora_defaults.availability_zones, null)
  backup_retention_period                  = try(each.value.backup_retention_period, var.rds_aurora_defaults.backup_retention_period, null)
  backtrack_window                         = try(each.value.backtrack_window, var.rds_aurora_defaults.backtrack_window, null)
  cluster_members                          = try(each.value.cluster_members, var.rds_aurora_defaults.cluster_members, null)
  copy_tags_to_snapshot                    = try(each.value.copy_tags_to_snapshot, var.rds_aurora_defaults.copy_tags_to_snapshot, null)
  database_name                            = try(each.value.database_name, var.rds_aurora_defaults.database_name, null)
  cluster_instance_class                   = try(each.value.cluster_instance_class, var.rds_aurora_defaults.cluster_instance_class, null)
  cluster_db_instance_parameter_group_name = try(each.value.cluster_db_instance_parameter_group_name, var.rds_aurora_defaults.cluster_db_instance_parameter_group_name, null)
  delete_automated_backups                 = try(each.value.delete_automated_backups, var.rds_aurora_defaults.delete_automated_backups, null)
  deletion_protection                      = try(each.value.deletion_protection, var.rds_aurora_defaults.deletion_protection, true)
  domain                                   = try(each.value.domain, var.rds_aurora_defaults.domain, null)
  domain_iam_role_name                     = try(each.value.domain_iam_role_name, var.rds_aurora_defaults.domain_iam_role_name, null)
  enable_global_write_forwarding           = try(each.value.enable_global_write_forwarding, var.rds_aurora_defaults.enable_global_write_forwarding, null)
  enabled_cloudwatch_logs_exports          = try(each.value.enabled_cloudwatch_logs_exports, var.rds_aurora_defaults.enabled_cloudwatch_logs_exports, [])
  enable_http_endpoint                     = try(each.value.enable_http_endpoint, var.rds_aurora_defaults.enable_http_endpoint, null)
  engine                                   = try(each.value.engine, var.rds_aurora_defaults.engine, null)
  engine_mode                              = try(each.value.engine_mode, var.rds_aurora_defaults.engine_mode, "provisioned")
  engine_version                           = try(each.value.engine_version, var.rds_aurora_defaults.engine_version, null)
  final_snapshot_identifier                = try(each.value.final_snapshot_identifier, var.rds_aurora_defaults.final_snapshot_identifier, null)
  global_cluster_identifier                = try(each.value.global_cluster_identifier, var.rds_aurora_defaults.global_cluster_identifier, null)
  iam_database_authentication_enabled      = try(each.value.iam_database_authentication_enabled, var.rds_aurora_defaults.iam_database_authentication_enabled, false) // autentica por iam role
  iops                                     = try(each.value.iops, var.rds_aurora_defaults.iops, null)
  kms_key_id                               = try(each.value.kms_key_id, var.rds_aurora_defaults.kms_key_id, null)
  network_type                             = try(each.value.network_type, var.rds_aurora_defaults.network_type, null) // IPV4 or DUAL
  port                                     = try(each.value.port, var.rds_aurora_defaults.port, 3306)
  predefined_metric_type                   = try(each.value.predefined_metric_type, var.rds_aurora_defaults.predefined_metric_type, "RDSReaderAverageCPUUtilization")
  preferred_backup_window                  = try(each.value.preferred_backup_window, var.rds_aurora_defaults.preferred_backup_window, "02:00-03:00")
  preferred_maintenance_window             = try(each.value.preferred_maintenance_window, var.rds_aurora_defaults.preferred_maintenance_window, "sun:05:00-sun:06:00")
  region                                   = try(each.value.region, var.rds_aurora_defaults.region, null)
  replication_source_identifier            = try(each.value.replication_source_identifier, var.rds_aurora_defaults.replication_source_identifier, null)
  restore_to_point_in_time                 = try(each.value.restore_to_point_in_time, var.rds_aurora_defaults.restore_to_point_in_time, null)
  scaling_configuration                    = try(each.value.scaling_configuration, var.rds_aurora_defaults.scaling_configuration, null)
  serverlessv2_scaling_configuration       = try(each.value.serverlessv2_scaling_configuration, var.rds_aurora_defaults.serverlessv2_scaling_configuration, null)
  skip_final_snapshot                      = try(each.value.skip_final_snapshot, var.rds_aurora_defaults.skip_final_snapshot, false)
  snapshot_identifier                      = try(each.value.snapshot_identifier, var.rds_aurora_defaults.snapshot_identifier, null)
  source_region                            = try(each.value.source_region, var.rds_aurora_defaults.source_region, null)
  storage_encrypted                        = try(each.value.storage_encrypted, var.rds_aurora_defaults.storage_encrypted, true) // necesita kms id
  storage_type                             = try(each.value.storage_type, var.rds_aurora_defaults.storage_type, "aurora")
  cluster_tags                             = try(each.value.cluster_tags, var.rds_aurora_defaults.cluster_tags, local.common_tags)
  cluster_timeouts                         = try(each.value.cluster_timeouts, var.rds_aurora_defaults.cluster_timeouts, {})
  enable_local_write_forwarding            = try(each.value.enable_local_write_forwarding, var.rds_aurora_defaults.enable_local_write_forwarding, null)
  cluster_ca_cert_identifier               = try(each.value.cluster_ca_cert_identifier, var.rds_aurora_defaults.cluster_ca_cert_identifier, null)
  engine_lifecycle_support                 = try(each.value.engine_lifecycle_support, var.rds_aurora_defaults.engine_lifecycle_support, null)
  cluster_monitoring_interval              = try(each.value.cluster_monitoring_interval, var.rds_aurora_defaults.cluster_monitoring_interval, 0)
  cluster_scalability_type                 = try(each.value.cluster_scalability_type, var.rds_aurora_defaults.cluster_scalability_type, null)
  database_insights_mode                   = try(each.value.database_insights_mode, var.rds_aurora_defaults.database_insights_mode, null)

  /*---------------------------*/
  /* Instances                 */
  /*---------------------------*/
  instances                       = try(each.value.instances, var.rds_aurora_defaults.instances, {})
  endpoints                       = try(each.value.endpoints, var.rds_aurora_defaults.endpoints, {})
  instances_use_identifier_prefix = try(each.value.instances_use_identifier_prefix, var.rds_aurora_defaults.instances_use_identifier_prefix, false)
  instance_timeouts               = try(each.value.instance_timeouts, var.rds_aurora_defaults.instance_timeouts, {})

  /*---------------------------*/
  /* Managed Secret Rotation   */
  /*---------------------------*/
  manage_master_user_password                            = false
  master_user_secret_kms_key_id                          = try(each.value.master_user_secret_kms_key_id, var.rds_aurora_defaults.master_user_secret_kms_key_id, null)
  master_username                                        = try(each.value.master_username, var.rds_aurora_defaults.master_username, "root")
  master_password_wo                                     = try(each.value.master_password_wo, each.value.master_password, var.rds_aurora_defaults.master_password_wo, var.rds_aurora_defaults.master_password, random_password.this[each.key].result)
  master_password_wo_version                             = try(each.value.master_password_wo_version, var.rds_aurora_defaults.master_password_wo_version, 1)
  manage_master_user_password_rotation                   = try(each.value.manage_master_user_password_rotation, var.rds_aurora_parameters.manage_master_user_password_rotation, false)
  master_user_password_rotate_immediately                = try(each.value.master_user_password_rotate_immediately, var.rds_aurora_defaults.master_user_password_rotate_immediately, null)
  master_user_password_rotation_automatically_after_days = try(each.value.master_user_password_rotation_automatically_after_days, var.rds_aurora_defaults.master_user_password_rotation_automatically_after_days, null)
  master_user_password_rotation_duration                 = try(each.value.master_user_password_rotation_duration, var.rds_aurora_defaults.master_user_password_rotation_duration, null)
  master_user_password_rotation_schedule_expression      = try(each.value.master_user_password_rotation_schedule_expression, var.rds_aurora_defaults.master_user_password_rotation_schedule_expression, null)

  /*---------------------------*/
  /* Cluster Parameter Group   */
  /*---------------------------*/
  cluster_parameter_group      = try(each.value.cluster_parameter_group, var.rds_aurora_defaults.cluster_parameter_group, local.rds_cluster_parameter_group[each.key])
  cluster_parameter_group_name = local.rds_cluster_parameter_group[each.key] != null ? null : try(each.value.cluster_parameter_group_name, var.rds_aurora_defaults.cluster_parameter_group_name, null)

  /*---------------------------*/
  /* Parameter Group           */
  /*---------------------------*/
  db_parameter_group = try(each.value.db_parameter_group, var.rds_aurora_defaults.db_parameter_group, local.rds_db_parameter_group[each.key])

  /*---------------------------*/
  /* Security Group            */
  /*---------------------------*/
  create_security_group  = false
  vpc_security_group_ids = local.rds_vpc_security_group_ids[each.key]

  /*---------------------------*/
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
  cluster_activity_stream = try(each.value.cluster_activity_stream, var.rds_aurora_defaults.cluster_activity_stream, null)

  /*---------------------------*/
  /* Enhanced Monitoring       */
  /*---------------------------*/
  create_monitoring_role        = try(each.value.create_monitoring_role, var.rds_aurora_defaults.create_monitoring_role, true)
  monitoring_role_arn           = try(each.value.monitoring_role_arn, var.rds_aurora_defaults.monitoring_role_arn, null)
  iam_role_name                 = try(each.value.iam_role_name, var.rds_aurora_defaults.iam_role_name, "${local.common_name}-${each.key}-role")
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, var.rds_aurora_defaults.iam_role_use_name_prefix, false)
  iam_role_description          = try(each.value.iam_role_description, var.rds_aurora_defaults.iam_role_description, null)
  iam_role_path                 = try(each.value.iam_role_path, var.rds_aurora_defaults.iam_role_path, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, var.rds_aurora_defaults.iam_role_permissions_boundary, null)
  iam_role_max_session_duration = try(each.value.iam_role_max_session_duration, var.rds_aurora_defaults.iam_role_max_session_duration, null)
  role_associations             = try(each.value.role_associations, each.value.iam_roles, var.rds_aurora_defaults.role_associations, var.rds_aurora_defaults.iam_roles, {})
  s3_import                     = try(each.value.s3_import, var.rds_aurora_defaults.s3_import, null)

  /*---------------------------*/
  /* Cluster Performance       */
  /*---------------------------*/
  cluster_performance_insights_enabled          = try(each.value.cluster_performance_insights_enabled, var.rds_aurora_defaults.cluster_performance_insights_enabled, null)
  cluster_performance_insights_kms_key_id       = try(each.value.cluster_performance_insights_kms_key_id, var.rds_aurora_defaults.cluster_performance_insights_kms_key_id, null)
  cluster_performance_insights_retention_period = try(each.value.cluster_performance_insights_retention_period, var.rds_aurora_defaults.cluster_performance_insights_retention_period, null)

  /*---------------------------*/
  /* Shard Group               */
  /*---------------------------*/
  shard_group = try(each.value.shard_group, var.rds_aurora_defaults.shard_group, null)

  tags = merge(local.common_tags, try(each.value.tags, var.rds_aurora_defaults.tags, {}))
}