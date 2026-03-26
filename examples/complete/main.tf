module "wrapper_rds_aurora" {
  source = "../../"

  metadata = local.metadata

  rds_aurora_parameters = {
    "mysql-01" = {
      deletion_protection = false
      apply_immediately   = true
      skip_final_snapshot = true

      # subnets  = data.aws_subnets.public.ids # Default: ""
      # subnet_name = "${local.common_name_prefix}-public*" # Default: "${local.common_name_prefix}-private*"

      engine         = "aurora-mysql"
      engine_version = "8.0"

      # Instances
      instances = {
        1 = {
          instance_class = "db.t3.medium"
        }
      }

      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }

      # ALARMS CONFIGURATION
      enable_alarms = true # Default: false

      alarms_disabled = ["critical-CPUUtilization", "critical-EBSByteBalance", "critical-EBSIOBalance"] # if you need to disable an alarm

      alarms_overrides = {
        # "warning-CPUUtilization" = {
        #   "actions_enabled"     = true
        #   "evaluation_periods"  = 2
        #   "datapoints_to_alarm" = 2
        #   "threshold"           = 30
        #   "period"              = 180
        #   "treat_missing_data"  = "ignore"
        # }
      }

      alarms_custom = {
        # "warning-FreeableMemory" = {
        #   # This alarm helps to monitor low freeable memory which can mean that there is a spike in database connections or that your instance may be under high memory pressure.
        #   description = "FreeableMemory below 350 MB"
        #   threshold   = 367001600
        #   unit        = "Bytes"
        #   metric_name = "FreeableMemory"
        #   statistic   = "Average"
        #   namespace   = "AWS/RDS"
        #   period      = 60
        #   evaluation_periods = 15
        #   datapoints_to_alarm = 15
        #   comparison_operator = "LessThanThreshold"
        #   alarms_tags = {
        #     "alarm-level" = "WARN"
        #   }
        # }
        # "critical-FreeableMemory" = {
        #   description = "FreeableMemory below 250 MB"
        #   # This alarm helps to monitor low freeable memory which can mean that there is a spike in database connections or that your instance may be under high memory pressure.
        #   threshold   = 262144000
        #   unit        = "Bytes"
        #   metric_name = "FreeableMemory"
        #   statistic   = "Average"
        #   namespace   = "AWS/RDS"
        #   period      = 60
        #   evaluation_periods = 15
        #   datapoints_to_alarm = 15
        #   comparison_operator = "LessThanThreshold"
        #   alarms_tags = {
        #     "alarm-level" = "CRIT"
        #   }
        # }
        # "warning-CPUCreditBalance" = {
        #   description = "RDS CPUCreditBalance below 12 creditcs"
        #   # This alarm helps to monitor the number of earned CPU credits that an instance has accrued since it was launched or started. 
        #   threshold   = 12
        #   unit        = "Count"
        #   metric_name = "CPUCreditBalance"
        #   statistic   = "Average"
        #   namespace   = "AWS/RDS"
        #   period      = 60
        #   evaluation_periods = 3
        #   datapoints_to_alarm = 3
        #   comparison_operator = "LessThanThreshold"
        #   alarms_tags = {
        #     "alarm-level" = "WARN"
        #   }
        # }
        # "critical-CPUCreditBalance" = {
        #   description = "RDS CPUCreditBalance below 30 credits"
        #   # This alarm helps to monitor the number of earned CPU credits that an instance has accrued since it was launched or started.
        #   threshold   = 30
        #   unit        = "Count"
        #   metric_name = "CPUCreditBalance"
        #   statistic   = "Average"
        #   namespace   = "AWS/RDS"
        #   period      = 60
        #   evaluation_periods = 3
        #   datapoints_to_alarm = 3
        #   comparison_operator = "LessThanThreshold"
        #   alarms_tags = {
        #     "alarm-level" = "CRIT"
        #   }
        # }
      }

      # Parameter group
      cluster_parameter_group_parameters = [
        {
          name         = "connect_timeout"
          value        = 120
          apply_method = "immediate"
        },
        {
          name         = "innodb_lock_wait_timeout"
          value        = 300
          apply_method = "immediate"
        },
        # {
        #   name         = "log_output"
        #   value        = "FILE"
        #   apply_method = "immediate"
        # },
        {
          name         = "max_allowed_packet"
          value        = "67108864"
          apply_method = "immediate"
        },
        # {
        #   name         = "aurora_parallel_query"
        #   value        = "OFF"
        #   apply_method = "pending-reboot"
        # },
        {
          name         = "binlog_format"
          value        = "ROW"
          apply_method = "pending-reboot"
        },
        {
          name         = "log_bin_trust_function_creators"
          value        = 1
          apply_method = "immediate"
        },
        {
          name         = "require_secure_transport"
          value        = "OFF"
          apply_method = "immediate"
        },
        {
          name         = "tls_version"
          value        = "TLSv1.2"
          apply_method = "pending-reboot"
        }
      ]
      db_parameter_group_parameters = [
        {
          name         = "connect_timeout"
          value        = 60
          apply_method = "immediate"
        },
        {
          name         = "general_log"
          value        = 0
          apply_method = "immediate"
        },
        {
          name         = "innodb_lock_wait_timeout"
          value        = 300
          apply_method = "immediate"
        },
        {
          name         = "log_output"
          value        = "FILE"
          apply_method = "pending-reboot"
        },
        {
          name         = "long_query_time"
          value        = 5
          apply_method = "immediate"
        },
        {
          name         = "max_connections"
          value        = 2000
          apply_method = "immediate"
        },
        {
          name         = "slow_query_log"
          value        = 1
          apply_method = "immediate"
        },
        {
          name         = "log_bin_trust_function_creators"
          value        = 1
          apply_method = "immediate"
        }
      ]

      # Monitoring & logs
      enabled_cloudwatch_logs_exports = ["error", "slowquery"]

      # DB Management
      enable_db_management                    = true
      enable_db_management_logs_notifications = true
      db_management_parameters = {
        databases = [
          {
            name    = "mydb1"
            charset = "utf8mb4"
            collate = "utf8mb4_general_ci"
          },
          {
            name    = "mydb2"
            charset = "utf8mb4"
            collate = "utf8mb4_general_ci"
          },
          {
            name    = "mydb3"
            charset = "utf8mb4"
            collate = "utf8mb4_general_ci"
          }
        ],
        users = [
          {
            username = "user1"
            host     = "%"
            password = "password1"
            grants = [
              {
                database   = "mydb1"
                table      = "*"
                privileges = "ALL"
              },
              {
                database   = "mydb2"
                table      = "*"
                privileges = "SELECT, UPDATE"
              }
            ]
          },
          {
            username = "user2"
            host     = "%"
            password = "password2"
            grants = [
              {
                database   = "mydb2"
                table      = "*"
                privileges = "ALL"
              }
            ]
          }
        ],
        excluded_users = ["rdsadmin", "root", "mysql.infoschema", "mysql.session", "mysql.sys", "healthcheck", "AWS_BEDROCK_ACCESS", "AWS_COMPREHEND_ACCESS", "AWS_LAMBDA_ACCESS", "AWS_LOAD_S3_ACCESS", "AWS_SAGEMAKER_ACCESS", "AWS_SELECT_S3_ACCESS", "rds_superuser_role"]
      }

      # DB Dump
      enable_db_dump_create                    = true
      db_dump_create_local_path_custom_scripts = "${path.module}/content/custom_sql"
      db_dump_create_schedule_expression       = "cron(0 * * * ? *)"
      db_dump_create_db_name                   = "mydb1"
      db_dump_create_retention_in_days         = 7
      db_dump_create_s3_arn_permission_accounts = [
        "arn:aws:iam::565219270600:root", # democorp
      ]

      enable_db_dump_restore         = true
      db_dump_restore_s3_bucket_name = "dmc-prd-example-00-aurora-db-dump-create"
      db_dump_restore_db_name        = "mydb1"

    }

    "pgsql-01" = {
      deletion_protection = false
      apply_immediately   = true
      skip_final_snapshot = true

      engine         = "aurora-postgresql"
      engine_version = "16"
      port           = "5432"

      # Instances
      instances = {
        1 = {
          instance_class = "db.t3.medium"
        }
      }
      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }

      # ingress_with_cidr_blocks = [
      #   {
      #     rule        = "postgresql-tcp"
      #     cidr_blocks = "0.0.0.0/0"
      #   }
      # ]

      # Parameter group
      cluster_parameter_group_parameters = [
        {
          name         = "log_min_duration_statement"
          value        = 4000
          apply_method = "immediate"
        } #,
        # {
        #   name         = "rds.force_ssl"
        #   value        = 1
        #   apply_method = "immediate"
        # }
      ]
      db_parameter_group_parameters = [
        {
          name         = "log_min_duration_statement"
          value        = 4000
          apply_method = "immediate"
        }
      ]

      # Monitoring & logs
      enabled_cloudwatch_logs_exports = ["postgresql"] # Default = []

      enable_db_management                    = true
      enable_db_management_logs_notifications = true
      db_management_parameters = {
        databases = [
          {
            "name" : "db1",
            "owner" : "root",
            "schemas" : [
              {
                "name" : "public",
                "owner" : "root"
              },
              {
                "name" : "schema1",
                "owner" : "usr1"
              }
            ]
          },
          {
            "name" : "db2",
            "owner" : "usr2",
          }
        ],
        users = [
          {
            "username" : "usr1",
            "password" : "passwd1",
            "grants" : [
              {
                "database" : "db1",
                "schema" : "public",
                "privileges" : "ALL PRIVILEGES",
                "table" : "*",
              }
            ]
          },
          {
            "username" : "usr2",
            "password" : "passwd2",
            "grants" : []
          }
        ],
        excluded_users = ["rdsadmin", "root", "healthcheck"]
      }
    }

    "mysql-public-01" = {
      deletion_protection = false
      apply_immediately   = true
      skip_final_snapshot = true

      engine         = "aurora-mysql"
      engine_version = "8.0"
      subnets        = data.aws_subnets.public.ids

      # Instances (publicly_accessible va por instancia en v10)
      instances = {
        1 = {
          instance_class      = "db.t3.medium"
          publicly_accessible = true
        }
      }

      dns_records = {
        "" = {
          zone_name    = local.zone_public # Create Public DNS Record
          private_zone = false
        }
      }

      # Open SecurityGroup to any host
      ingress_with_cidr_blocks = [
        {
          rule        = "mysql-tcp"
          cidr_blocks = "0.0.0.0/0"
        }
      ]

      # DB Management
      enable_db_management                    = true
      enable_db_management_logs_notifications = true
      db_management_parameters = {
        databases = [
          {
            name    = "mydb1"
            charset = "utf8mb4"
            collate = "utf8mb4_general_ci"
          }
        ],
        users = [
          {
            username = "user1"
            host     = "%"
            password = "password1"
            grants = [
              {
                database   = "mydb1"
                table      = "*"
                privileges = "ALL"
              }
            ]
          }
        ],
        excluded_users = ["rdsadmin", "root", "mysql.infoschema", "mysql.session", "mysql.sys", "healthcheck", "AWS_BEDROCK_ACCESS", "AWS_COMPREHEND_ACCESS", "AWS_LAMBDA_ACCESS", "AWS_LOAD_S3_ACCESS", "AWS_SAGEMAKER_ACCESS", "AWS_SELECT_S3_ACCESS", "rds_superuser_role"]
      }
    }

    "postgres-cluster" = {
      engine_version         = "17.4"
      engine                 = "postgres"
      cluster_instance_class = "db.m5d.large"
      port                   = 5432

      subnets = data.aws_subnets.private.ids

      # CLUSTER CONFIG
      create_db_parameter_group               = false
      create_cluster_parameter_group          = true
      cluster_parameter_group_family          = "postgres17"
      cluster_parameter_group_name            = "postgres17-01"
      cluster_parameter_group_use_name_prefix = false
      cluster_parameter_group_parameters = [
        {
          apply_method = "immediate"
          name         = "log_min_duration_statement"
          value        = "59000"
        }
      ]

      # Multi-AZ
      availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
      allocated_storage  = 500
      iops               = 12000
      storage_type       = "gp3"

      enable_local_write_forwarding = false
      skip_final_snapshot           = true

      dns_records = {}

      database_name   = "postgrescluster"
      master_username = "master_user"
      master_password = "master_pass"

      deletion_protection = false

      preferred_backup_window      = "04:31-05:01"
      preferred_maintenance_window = "mon:06:19-mon:06:49"
      apply_immediately            = true
      copy_tags_to_snapshot        = true

      ingress_with_cidr_blocks = []
    }
  }

  rds_aurora_defaults = var.rds_aurora_defaults
}