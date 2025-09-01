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
| [terraform-aws-modules/eventbridge/aws](https://github.com/terraform-aws-modules/eventbridge-aws) | 4.1.0 |
| [terraform-aws-modules/lambda/aws](https://github.com/terraform-aws-modules/lambda-aws) | 8.0.1 |
| [terraform-aws-modules/lambda/aws](https://github.com/terraform-aws-modules/lambda-aws) | 7.19.0 |
| [terraform-aws-modules/rds-aurora/aws](https://github.com/terraform-aws-modules/rds-aurora-aws) | 9.15.0 |
| [terraform-aws-modules/s3-bucket/aws](https://github.com/terraform-aws-modules/s3-bucket-aws) | 5.2.0 |
| [terraform-aws-modules/security-group/aws](https://github.com/terraform-aws-modules/security-group-aws) | 5.3.0 |
| [terraform-aws-modules/ssm-parameter/aws](https://github.com/terraform-aws-modules/ssm-parameter-aws) | 1.1.2 |



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