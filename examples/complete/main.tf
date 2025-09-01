module "wrapper_rds_aurora" {
  source = "../../"

  metadata = local.metadata
  project  = local.project

  rds_aurora_parameters = {
    "mysql-01" = {
      deletion_protection = false
      apply_immediately   = true
      skip_final_snapshot = true

      # subnets  = data.aws_subnets.public.ids # Default: ""
      # subnet_name = "${local.common_name_prefix}-public*" # Default: "${local.common_name_prefix}-private*"

      engine                 = "aurora-mysql"
      engine_version         = "8.0"
      parameter_group_family = "aurora-mysql8.0"

      # Instances
      instances = {
        1 = {
          # identifier     = "master-member-1" # Optional custom instance name
          instance_class = "db.t3.medium"
        }
      }

      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
        }
      }

      # Parameter group
      db_cluster_parameter_group_parameters = [
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

      engine                 = "aurora-postgresql"
      engine_version         = "16.2"
      parameter_group_family = "aurora-postgresql16"

      port = "5432"

      # Instances
      instances = {
        1 = {
          instance_class = "db.t3.medium"
        }
      }
      # publicly_accessible = true # Default = false
      # subnets             = data.aws_subnets.public.ids
      dns_records = {
        "" = {
          zone_name    = local.zone_private
          private_zone = true
          # zone_name    = local.zone_public # Create Public DNS Record
          # private_zone = false
        }
      }

      # ingress_with_cidr_blocks = [
      #   {
      #     rule        = "postgresql-tcp"
      #     cidr_blocks = "0.0.0.0/0"
      #   }
      # ]

      # Parameter group
      db_cluster_parameter_group_parameters = [
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

      engine                 = "aurora-mysql"
      engine_version         = "8.0"
      parameter_group_family = "aurora-mysql8.0"

      publicly_accessible = true # Default = false
      subnets             = data.aws_subnets.public.ids

      # Instances
      instances = {
        1 = {
          instance_class = "db.t3.medium"
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

  }

  rds_aurora_defaults = var.rds_aurora_defaults
}