# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform RDS Aurora Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-rds-aurora/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-rds-aurora.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-rds-aurora.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-rds-aurora/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for RDS Aurora simplifies the configuration of the Relational Database Service in the AWS cloud. This wrapper functions as a predefined template, facilitating the creation and management of RDS Aurora instances by handling all the technical details.

### ✨ Features

- 🔐 [User and Database Management](#user-and-database-management) - Manages users, databases, and access with notifications; retains resources

- 💾 [Dump with S3](#dump-with-s3) - Generates SQL dumps and stores them in S3 with cleanup scripts for MySQL/MariaDB

- 💾 [Restore with S3](#restore-with-s3) - Restores database from SQL dump and runs cleanup scripts for MySQL/MariaDB

- 🌐 [DNS Record](#dns-record) - Registers a CNAME DNS record in a Route53 hosted zone



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-eventbridge" target="_blank">terraform-aws-modules/eventbridge/aws</a> | 4.1.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-lambda" target="_blank">terraform-aws-modules/lambda/aws</a> | 8.0.1 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-lambda" target="_blank">terraform-aws-modules/lambda/aws</a> | 7.19.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-rds-aurora" target="_blank">terraform-aws-modules/rds-aurora/aws</a> | 9.15.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-s3-bucket" target="_blank">terraform-aws-modules/s3-bucket/aws</a> | 5.2.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter" target="_blank">terraform-aws-modules/ssm-parameter/aws</a> | 1.1.2 |



## 🚀 Quick Start
```hcl
rds_aurora_parameters = {
  "mysql-00" = {
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
      }
    ]

    # Monitoring & logs
    enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  }

  "postgresql-00" = {
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

    dns_records = {
      "" = {
        zone_name    = local.zone_private
        private_zone = true
      }
    }

    # Parameter group
    db_cluster_parameter_group_parameters = [
      {
        name         = "log_min_duration_statement"
        value        = 4000
        apply_method = "immediate"
      },
      #{
      #  name         = "rds.force_ssl"
      #  value        = 0
      #  apply_method = "immediate"
      #}
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
  }
}
```


## 🔧 Additional Features Usage

### User and Database Management
Deploy lambda function, which manages the creation and modification of *Users*, *Databases*, and their access to them.
The credentials for the accesses will be stored in a parameter of **Parameter Store**.
Send notifications of the actions taken.
Does not remove databases or users; the latter will remain without permissions on the resources.


<details><summary>MySQL / MariaDB code</summary>

```hcl
rds_aurora_parameters = {
  "mysql" = {
    ...
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
    ...
  }
}
```


</details>

<details><summary>PostgreSQL code</summary>

```hcl
rds_aurora_parameters = {
  "postgresql" = {
    ...
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
    ...
  }
}
```


</details>


### Dump with S3
This module creates the necessary resources to generate an SQL dump and store it in an S3 bucket, along with cleanup scripts for the database. <br/> It supports the database engines **MySQL** and **MariaDB**.


<details><summary>Configuration Code</summary>

```hcl
rds_aurora_parameters = {
  "00" = {
    ...
    enable_db_dump_create = true
    db_dump_create_local_path_custom_scripts = "${path.module}/content/custom_sql"
    db_dump_create_schedule_expression = "cron(0 * * * ? *)"
    db_dump_create_db_name = "demo"
    db_dump_create_retention_in_days = 7
    db_dump_create_s3_arn_permission_accounts = [
      "arn:aws:iam::xxxxxxxxxxx:root", # demo.la-dev
      "arn:aws:iam::xxxxxxxxxxx:root", # demo.la-stg
    ]
    ...
  }
}
```


</details>


### Restore with S3
This module creates the necessary resources to perform a restore from an SQL dump stored in a bucket and execute the necessary cleanup scripts. <br/> It supports the database engines **MySQL** and **MariaDB**.


<details><summary>Configuration Code</summary>

```hcl
enable_db_dump_restore = true
db_dump_restore_s3_bucket_name = "demo-l04-core-00-db-dump-create"
db_dump_restore_db_name = "demo"
```


</details>


### DNS Record
Register a CNAME DNS record in a Route53 hosted zone that is present within the account, which can be public or private depending on the desired visibility type of the record.


<details><summary>Configuration Code</summary>

```hcl
dns_records = {
  "" = {
    # zone_name    = local.zone_private
    # private_zone = true
    zone_name    = local.zone_public
    private_zone = false
  }
}
```


</details>




## 📑 Inputs
| Name                                                | Description                                                                                                                                                                                                    | Type     | Default                                                          | Required |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------- | -------- |
| `create`                                            | Enables or disables the creation of the resource                                                                                                                                                               | `bool`   | `true`                                                           | no       |
| `name`                                              | Aurora RDS cluster name                                                                                                                                                                                        | `string` | `"${local.common_name}-${each.key}"`                             | no       |
| `create_db_subnet_group`                            | Indicates whether to create the subnet group                                                                                                                                                                   | `bool`   | `true`                                                           | no       |
| `db_subnet_group_name`                              | Name of the subnet group for the cluster                                                                                                                                                                       | `string` | `"${local.common_name}-${each.key}-sg"`                          | no       |
| `subnets`                                           | Subnets associated with the subnet group                                                                                                                                                                       | `list`   | `data.aws_subnets.this[each.key].ids`                            | no       |
| `cluster_use_name_prefix`                           | Indicates whether to use a prefix for the cluster name                                                                                                                                                         | `bool`   | `false`                                                          | no       |
| `is_primary_cluster`                                | Defines if the cluster is primary                                                                                                                                                                              | `bool`   | `true`                                                           | no       |
| `allocated_storage`                                 | Amount of allocated storage                                                                                                                                                                                    | `number` | `null`                                                           | no       |
| `allow_major_version_upgrade`                       | Allows major version upgrades                                                                                                                                                                                  | `bool`   | `false`                                                          | no       |
| `apply_immediately`                                 | Apply changes immediately                                                                                                                                                                                      | `bool`   | `false`                                                          | no       |
| `availability_zones`                                | Availability zones associated                                                                                                                                                                                  | `list`   | `null`                                                           | no       |
| `backup_retention_period`                           | Backup retention period                                                                                                                                                                                        | `number` | `null`                                                           | no       |
| `backtrack_window`                                  | Backtrack window                                                                                                                                                                                               | `number` | `null`                                                           | no       |
| `cluster_members`                                   | Cluster members                                                                                                                                                                                                | `list`   | `null`                                                           | no       |
| `copy_tags_to_snapshot`                             | Copy tags to snapshot                                                                                                                                                                                          | `bool`   | `null`                                                           | no       |
| `database_name`                                     | Database name                                                                                                                                                                                                  | `string` | `null`                                                           | no       |
| `db_cluster_instance_class`                         | Cluster instance class                                                                                                                                                                                         | `string` | `null`                                                           | no       |
| `db_cluster_db_instance_parameter_group_name`       | Name of the cluster parameter group                                                                                                                                                                            | `string` | `""`                                                             | no       |
| `delete_automated_backups`                          | Delete automated backups                                                                                                                                                                                       | `bool`   | `null`                                                           | no       |
| `deletion_protection`                               | Protection against deletion                                                                                                                                                                                    | `bool`   | `true`                                                           | no       |
| `enable_global_write_forwarding`                    | Enable global direct write                                                                                                                                                                                     | `bool`   | `null`                                                           | no       |
| `enabled_cloudwatch_logs_exports`                   | Types of logs exported to CloudWatch                                                                                                                                                                           | `list`   | `[]`                                                             | no       |
| `enable_http_endpoint`                              | Enable HTTP endpoint                                                                                                                                                                                           | `bool`   | `null`                                                           | no       |
| `engine`                                            | Database engine                                                                                                                                                                                                | `string` | `null`                                                           | no       |
| `engine_mode`                                       | Database engine mode                                                                                                                                                                                           | `string` | `"provisioned"`                                                  | no       |
| `engine_version`                                    | Engine version                                                                                                                                                                                                 | `string` | `null`                                                           | no       |
| `final_snapshot_identifier`                         | Identifier of the final snapshot                                                                                                                                                                               | `string` | `null`                                                           | no       |
| `global_cluster_identifier`                         | Identifier of the global cluster                                                                                                                                                                               | `string` | `null`                                                           | no       |
| `iam_database_authentication_enabled`               | Enable database authentication via IAM                                                                                                                                                                         | `bool`   | `false`                                                          | no       |
| `iops`                                              | Allocated IOPS                                                                                                                                                                                                 | `number` | `null`                                                           | no       |
| `kms_key_id`                                        | KMS key identifier                                                                                                                                                                                             | `string` | `null`                                                           | no       |
| `network_type`                                      | Network type (IPV4 or DUAL)                                                                                                                                                                                    | `string` | `null`                                                           | no       |
| `port`                                              | Database port                                                                                                                                                                                                  | `number` | `3306`                                                           | no       |
| `preferred_backup_window`                           | Preferred backup window                                                                                                                                                                                        | `string` | `"02:00-03:00"`                                                  | no       |
| `preferred_maintenance_window`                      | Preferred maintenance window                                                                                                                                                                                   | `string` | `"sun:05:00-sun:06:00"`                                          | no       |
| `replication_source_identifier`                     | Identifier of the replication source                                                                                                                                                                           | `string` | `null`                                                           | no       |
| `restore_to_point_in_time`                          | Configuration to restore to a point in time                                                                                                                                                                    | `map`    | `{}`                                                             | no       |
| `scaling_configuration`                             | Scalability configuration (for serverless mode)                                                                                                                                                                | `map`    | `{}`                                                             | no       |
| `serverlessv2_scaling_configuration`                | Scalability configuration for serverless v2                                                                                                                                                                    | `map`    | `{}`                                                             | no       |
| `skip_final_snapshot`                               | Indicates whether to skip the final snapshot                                                                                                                                                                   | `bool`   | `false`                                                          | no       |
| `snapshot_identifier`                               | Snapshot identifier                                                                                                                                                                                            | `string` | `null`                                                           | no       |
| `source_region`                                     | Source region                                                                                                                                                                                                  | `string` | `null`                                                           | no       |
| `storage_encrypted`                                 | Indicates if storage is encrypted                                                                                                                                                                              | `bool`   | `true`                                                           | no       |
| `storage_type`                                      | Storage type                                                                                                                                                                                                   | `string` | `"aurora"`                                                       | no       |
| `cluster_tags`                                      | Tags for the cluster                                                                                                                                                                                           | `map`    | `local.common_tags`                                              | no       |
| `vpc_security_group_ids`                            | Identifiers of the VPC security groups                                                                                                                                                                         | `list`   | `[module.security_group_rds[each.key].security_group_id]`        | no       |
| `cluster_timeouts`                                  | Timeout configuration for the cluster                                                                                                                                                                          | `map`    | `{}`                                                             | no       |
| `enable_local_write_forwarding`                     | Enable local write forwarding                                                                                                                                                                                  | `bool`   | `null`                                                           | no       |
| `cluster_ca_cert_identifier`                        | Identifier of the cluster CA certificate                                                                                                                                                                       | `string` | `null`                                                           | no       |
| `engine_lifecycle_support`                          | Engine lifecycle support                                                                                                                                                                                       | `string` | `null`                                                           | no       |
| `instances`                                         | Configuration of the cluster instances                                                                                                                                                                         | `map`    | `{}`                                                             | no       |
| `endpoints`                                         | Endpoint configuration                                                                                                                                                                                         | `map`    | `{}`                                                             | no       |
| `auto_minor_version_upgrade`                        | Enable automatic minor version upgrade                                                                                                                                                                         | `bool`   | `true`                                                           | no       |
| `ca_cert_identifier`                                | CA certificate identifier for instances                                                                                                                                                                        | `string` | `null`                                                           | no       |
| `instances_use_identifier_prefix`                   | Use prefix in instance identifiers                                                                                                                                                                             | `bool`   | `false`                                                          | no       |
| `instance_class`                                    | Instance class                                                                                                                                                                                                 | `string` | `""`                                                             | no       |
| `monitoring_interval`                               | Monitoring interval in seconds                                                                                                                                                                                 | `number` | `0`                                                              | no       |
| `performance_insights_enabled`                      | Enable Performance Insights metrics                                                                                                                                                                            | `bool`   | `null`                                                           | no       |
| `performance_insights_kms_key_id`                   | KMS key identifier for Performance Insights                                                                                                                                                                    | `string` | `null`                                                           | no       |
| `performance_insights_retention_period`             | Retention period for Performance Insights metrics                                                                                                                                                              | `number` | `null`                                                           | no       |
| `publicly_accessible`                               | Indicate if the instance is publicly accessible                                                                                                                                                                | `bool`   | `false`                                                          | no       |
| `instance_timeouts`                                 | Timeout settings configuration for instances                                                                                                                                                                   | `map`    | `{}`                                                             | no       |
| `manage_master_user_password`                       | Indicate if the master user password should be managed                                                                                                                                                         | `bool`   | `false`                                                          | no       |
| `master_user_secret_kms_key_id`                     | KMS key identifier for master user secret                                                                                                                                                                      | `string` | `null`                                                           | no       |
| `master_username`                                   | Master user name                                                                                                                                                                                               | `string` | `"root"`                                                         | no       |
| `master_password`                                   | Master user password                                                                                                                                                                                           | `string` | `"${random_password.this[each.key].result}"`                     | no       |
| `manage_master_user_password_rotation`              | Enable automatic rotation of master user password                                                                                                                                                              | `bool`   | `false`                                                          | no       |
| `master_user_password_rotate_immediately`           | Immediate rotation of master user password                                                                                                                                                                     | `bool`   | `null`                                                           | no       |
| `master_user_password_rotation_duration`            | Duration of master user password rotation                                                                                                                                                                      | `number` | `null`                                                           | no       |
| `master_user_password_rotation_schedule_expression` | Schedule expression for password rotation                                                                                                                                                                      | `string` | `null`                                                           | no       |
| `create_db_cluster_parameter_group`                 | Create parameter group for the cluster                                                                                                                                                                         | `bool`   | `true`                                                           | no       |
| `db_cluster_parameter_group_name`                   | Cluster parameter group name                                                                                                                                                                                   | `string` | `"${local.common_name}-${each.key}-cpg"`                         | no       |
| `db_cluster_parameter_group_family`                 | Parameter group family for the cluster                                                                                                                                                                         | `string` | `null`                                                           | no       |
| `db_cluster_parameter_group_description`            | Cluster parameter group description                                                                                                                                                                            | `string` | `"Cluster parameter group for ${local.common_name}-${each.key}"` | no       |
| `db_cluster_parameter_group_parameters`             | Cluster parameter group parameters                                                                                                                                                                             | `list`   | `[]`                                                             | no       |
| `create_db_parameter_group`                         | Create database parameter group                                                                                                                                                                                | `bool`   | `true`                                                           | no       |
| `db_parameter_group_name`                           | Database parameter group name                                                                                                                                                                                  | `string` | `"${local.common_name}-${each.key}-pg"`                          | no       |
| `db_parameter_group_family`                         | Parameter group family for the database                                                                                                                                                                        | `string` | `null`                                                           | no       |
| `db_parameter_group_description`                    | Database parameter group description                                                                                                                                                                           | `string` | `"Parameter group for ${local.common_name}-${each.key}"`         | no       |
| `db_parameter_group_parameters`                     | Database parameter group parameters                                                                                                                                                                            | `list`   | `[]`                                                             | no       |
| `create_security_group`                             | Create a Security Group for the cluster                                                                                                                                                                        | `bool`   | `false`                                                          | no       |
| `security_group_name`                               | Security Group name                                                                                                                                                                                            | `string` | `"${local.common_name}-rds-${each.key}"`                         | no       |
| `security_group_use_name_prefix`                    | Use prefix for Security Group name                                                                                                                                                                             | `bool`   | `false`                                                          | no       |
| `security_group_description`                        | Security Group description                                                                                                                                                                                     | `string` | `"Security Group for ${local.common_name}-${each.key}"`          | no       |
| `vpc_id`                                            | VPC ID where the Security Group will be created                                                                                                                                                                | `string` | `data.aws_vpc.this[each.key].id`                                 | no       |
| `security_group_rules`                              | Security Group rules                                                                                                                                                                                           | `map`    | `{}`                                                             | no       |
| `create_cloudwatch_log_group`                       | Create a CloudWatch Log Group for the cluster                                                                                                                                                                  | `bool`   | `true`                                                           | no       |
| `cloudwatch_log_group_retention_in_days`            | Log retention in days                                                                                                                                                                                          | `number` | `7`                                                              | no       |
| `cloudwatch_log_group_kms_key_id`                   | KMS key ID for encrypting logs                                                                                                                                                                                 | `string` | `null`                                                           | no       |
| `cloudwatch_log_group_skip_destroy`                 | Skip log group destruction when deleting resources                                                                                                                                                             | `bool`   | `null`                                                           | no       |
| `cloudwatch_log_group_class`                        | Log group class                                                                                                                                                                                                | `string` | `null`                                                           | no       |
| `create_db_cluster_activity_stream`                 | Create an Activity Stream for the cluster                                                                                                                                                                      | `bool`   | `false`                                                          | no       |
| `db_cluster_activity_stream_kms_key_id`             | KMS key ID for the Activity Stream                                                                                                                                                                             | `string` | `""`                                                             | no       |
| `db_cluster_activity_stream_mode`                   | Cluster Activity Stream mode (async/sync)                                                                                                                                                                      | `string` | `"async"`                                                        | no       |
| `create_monitoring_role`                            | Create a monitoring role for Enhanced Monitoring                                                                                                                                                               | `bool`   | `true`                                                           | no       |
| `monitoring_role_arn`                               | Monitoring role ARN for Enhanced Monitoring                                                                                                                                                                    | `string` | `"${local.common_name}-rds-monitoring-${each.key}"`              | no       |
| `iam_role_name`                                     | IAM role name                                                                                                                                                                                                  | `string` | `"${local.common_name}-${each.key}-role"`                        | no       |
| `iam_role_use_name_prefix`                          | Use prefix for IAM role name                                                                                                                                                                                   | `bool`   | `false`                                                          | no       |
| `iam_role_description`                              | IAM role description                                                                                                                                                                                           | `string` | `null`                                                           | no       |
| `iam_role_path`                                     | IAM role path                                                                                                                                                                                                  | `string` | `null`                                                           | no       |
| `iam_role_managed_policy_arns`                      | Managed policy ARNs for the IAM role                                                                                                                                                                           | `list`   | `null`                                                           | no       |
| `iam_role_permissions_boundary`                     | Permission limit for the IAM role                                                                                                                                                                              | `string` | `null`                                                           | no       |
| `iam_role_force_detach_policies`                    | Force disconnection of policies when deleting the IAM role                                                                                                                                                     | `bool`   | `null`                                                           | no       |
| `iam_role_max_session_duration`                     | Maximum duration of the IAM role session in seconds                                                                                                                                                            | `number` | `null`                                                           | no       |
| `cluster_performance_insights_enabled`              | Enable Performance Insights for the cluster                                                                                                                                                                    | `bool`   | `null`                                                           | no       |
| `cluster_performance_insights_kms_key_id`           | KMS key ID to encrypt Performance Insights data                                                                                                                                                                | `string` | `null`                                                           | no       |
| `cluster_performance_insights_retention_period`     | Retention period for Performance Insights data                                                                                                                                                                 | `number` | `null`                                                           | no       |
| `cluster_monitoring_interval`                       | Interval, in seconds, between points at which Enhanced Monitoring metrics are collected for the DB cluster                                                                                                     | `number` | `0`                                                              | no       |
| `cloudwatch_log_group_tags`                         | Additional tags for the Cloudwatch log group(s)                                                                                                                                                                | `map`    | `{}`                                                             | no       |
| `cluster_scalability_type`                          | Scalability mode of the database cluster. When set to unlimited, the cluster operates as an Aurora database without limits. When set to standard (default), the cluster uses normal database instance creation | `string` | `null`                                                           | no       |
| `database_insights_mode`                            | Mode in which Database Insights will be enabled for the database cluster                                                                                                                                       | `string` | `null`                                                           | no       |
| `create_shard_group`                                | Create a shard group                                                                                                                                                                                           | `bool`   | `false`                                                          | no       |
| `compute_redundancy`                                | Specifies whether to create standby database shard groups                                                                                                                                                      | `number` | `null`                                                           | no       |
| `db_shard_group_identifier`                         | Name of the DB shard group                                                                                                                                                                                     | `string` | `null`                                                           | no       |
| `max_acu`                                           | Maximum capacity of the DB shard group in Aurora Capacity Units (ACU)                                                                                                                                          | `number` | `null`                                                           | no       |
| `min_acu`                                           | Minimum capacity of the DB shard group in Aurora Capacity Units (ACU)                                                                                                                                          | `number` | `null`                                                           | no       |
| `shard_group_tags`                                  | Additional tags for the shard group                                                                                                                                                                            | `map`    | `{}`                                                             | no       |
| `shard_group_timeouts`                              | Create, update, and delete timeout settings for the shard group                                                                                                                                                | `map`    | `{}`                                                             | no       |
| `tags`                                              | Additional tags for the resource                                                                                                                                                                               | `map`    | `{}`                                                             | no       |







## ⚠️ Important Notes
- **🚨 Restart Engine During Changes:** Restart the engine during parameter group changes - set `apply_immediately = true`
- **⚠️ Public Access:** Exposes the resource to the internet - set `publicly_accessible = true`
- **⚠️ Overwrite Database Data:** Allows overwriting data in the database engine - set `force_replace_data = true`
- **ℹ️ Storage Growth Limit:** Enables unlimited storage growth - set `max_allocated_storage = null`



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la
- 🐛 **Issues**: [GitHub Issues](https://github.com/gocloudLa/issues)

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 