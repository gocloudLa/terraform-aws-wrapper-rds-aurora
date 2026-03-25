#########################################################################################################################################
#                                                                                                                                       #
# Documentation: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Best_Practice_Recommended_Alarms_AWS_Services.html#RDS  #                                                 #
#                                                                                                                                       #
#########################################################################################################################################

locals {
  alarms_default = {
    "warning-CPUUtilization" = {
      # This alarm is used to detect a high DB load.
      description         = "is using more than 75% of CPU"
      threshold           = 75
      unit                = "Percent"
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 5
      datapoints_to_alarm = 5
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-CPUUtilization" = {
      # This alarm is used to detect a high DB load.
      description         = "is using more than 90% of CPU"
      threshold           = 90
      unit                = "Percent"
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 5
      datapoints_to_alarm = 5
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-EBSByteBalance" = {
      # THIS ALARM IS NOT RECOMMENDED FOR AURORA POSTGRESQL INTANCES.
      # Is used to detect a low percentage of throughput credits remaining in the burst bucket (Low byte b3alance percentage can cause throughput bottleneck issues).
      description         = "is less than 20% of EBSByte"
      threshold           = 20
      unit                = "Percent"
      metric_name         = "EBSByteBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-EBSByteBalance" = {
      # THIS ALARM IS NOT RECOMMENDED FOR AURORA POSTGRESQL INTANCES.
      # Is used to detect a low percentage of throughput credits remaining in the burst bucket (Low byte balance percentage can cause throughput bottleneck issues).
      description         = "is less than 10% of EBSByte"
      threshold           = 10
      unit                = "Percent"
      metric_name         = "EBSByteBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-EBSIOBalance" = {
      # THIS ALARM IS NOT RECOMMENDED FOR AURORA POSTGRESQL INTANCES.
      # Is used to detect a low percentage of I/O credits remaining in the burst bucket (Low IOPS balance percentage can cause IOPS bottleneck issues).
      description         = "is less than 20% of EBSIO"
      threshold           = 20
      unit                = "Percent"
      metric_name         = "EBSIOBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-EBSIOBalance" = {
      # THIS ALARM IS NOT RECOMMENDED FOR AURORA POSTGRESQL INTANCES.
      # Is used to detect a low percentage of I/O credits remaining in the burst bucket (Low IOPS balance percentage can cause IOPS bottleneck issues).
      description         = "is less than 10% of EBSIO"
      threshold           = 10
      unit                = "Percent"
      metric_name         = "EBSIOBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-ReadLatency" = {
      # This alarm helps to monitor high read latency. If storage latency is high, it's because the workload is exceeding resource limits.
      description         = "ReadLatency p90 above 10 ms for 5 consecutive minutes"
      threshold           = 0.02
      unit                = "Seconds"
      metric_name         = "ReadLatency"
      extended_statistic  = "p90"
      namespace           = "AWS/RDS"
      evaluation_periods  = 5
      datapoints_to_alarm = 5
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "warning-WriteLatency" = {
      # This alarm helps to monitor high write latency. If storage latency is high, it's because the workload is exceeding resource limits.
      description         = "WriteLatency p90 above 10 ms for 5 consecutive minutes"
      threshold           = 0.02
      unit                = "Seconds"
      metric_name         = "WriteLatency"
      extended_statistic  = "p90"
      namespace           = "AWS/RDS"
      evaluation_periods  = 5
      datapoints_to_alarm = 5
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
  }
  alarms_default_tmp = merge([
    for rds_name, values in try(var.rds_aurora_parameters, []) : {
      for alarm, value in try(local.alarms_default, {}) :
      "${rds_name}-${alarm}" =>
      merge(
        value,
        {
          alarm_name          = alarm
          alarm_description   = "Rds[${rds_name}] ${value.description}"
          actions_enabled     = try(values.alarms_overrides[alarm].actions_enabled, true)
          threshold           = try(values.alarms_overrides[alarm].threshold, value.threshold)
          unit                = try(values.alarms_overrides[alarm].unit, value.unit)
          metric_name         = try(values.alarms_overrides[alarm].metric_name, value.metric_name)
          namespace           = try(values.alarms_overrides[alarm].namespace, value.namespace, "AWS/RDS")
          evaluation_periods  = try(values.alarms_overrides[alarm].evaluation_periods, value.evaluation_periods, null)
          datapoints_to_alarm = try(values.alarms_overrides[alarm].datapoints_to_alarm, value.datapoints_to_alarm, null)
          statistic           = try(values.alarms_overrides[alarm].statistic, value.statistic, null)
          extended_statistic  = try(values.alarms_overrides[alarm].extended_statistic, value.extended_statistic, null)
          comparison_operator = try(values.alarms_overrides[alarm].comparison_operator, value.comparison_operator)
          period              = try(values.alarms_overrides[alarm].period, value.period, 60)
          treat_missing_data  = try(values.alarms_overrides[alarm].treat_missing_data, "notBreaching")
          dimensions = try(value.dimensions, {
            DBInstanceIdentifier = "${local.common_name}-${rds_name}"
          })
          ok_actions    = try(values.alarms_overrides[alarm].ok_actions, value.ok_actions, [])
          alarm_actions = try(values.alarms_overrides[alarm].alarm_actions, value.alarm_actions, [])
          alarms_tags   = merge(try(values.alarms_overrides[alarm].alarms_tags, value.alarms_tags), { "alarm-rds-name" = "${local.common_name}-${rds_name}" })
      }) if can(var.rds_aurora_parameters) && var.rds_aurora_parameters != {} && try(values.enable_alarms, false) && !contains(try(values.alarms_disabled, []), alarm)
    }
  ]...)

  alarms_custom_tmp = merge([
    for rds_name, values in try(var.rds_aurora_parameters, []) : {
      for alarm, value in try(values.alarms_custom, {}) :
      "${rds_name}-${alarm}" => merge(
        value,
        {
          alarm_name          = alarm
          alarm_description   = try(value.description, "")
          actions_enabled     = try(value.actions_enabled, true)
          threshold           = value.threshold
          unit                = value.unit
          metric_name         = value.metric_name
          namespace           = try(value.namespace, "AWS/RDS")
          evaluation_periods  = try(value.evaluation_periods, null)
          datapoints_to_alarm = try(value.datapoints_to_alarm, null)
          statistic           = try(value.statistic, null)
          extended_statistic  = try(value.extended_statistic, null)
          comparison_operator = value.comparison_operator
          period              = value.period
          treat_missing_data  = try("${value.treat_missing_data}", "notBreaching")
          dimensions = try(value.dimensions, {
            DBInstanceIdentifier = "${local.common_name}-${rds_name}"
          })
          ok_actions    = try(value.ok_actions, [])
          alarm_actions = try(value.alarm_actions, [])
          alarms_tags   = merge(try(values.alarms_overrides[alarm].alarms_tags, value.alarms_tags), { "alarm-rds-name" = "${local.common_name}-${rds_name}" })
        }
      ) if can(var.rds_aurora_parameters) && var.rds_aurora_parameters != {} && try(values.enable_alarms, false)
    }
  ]...)

  alarms = merge(
    local.alarms_default_tmp,
    local.alarms_custom_tmp
  )

  # RDS / Aurora instance-level alarms - creates a flat map for for_each
  alarms_for_cluster = merge(flatten([
    for cluster_name, cluster_config in var.rds_aurora_parameters : [
      # Iterate through each RDS/Aurora cluster and for each cluster iterate through its member instances (cluster_members)
      # This creates alarms for each individual instance in the cluster
      for instance_id in tolist(module.rds_aurora[cluster_name].cluster_members) : [
        for alarm_name, alarm in local.alarms : {
          "${cluster_name}-${instance_id}-${alarm_name}" = merge(
            alarm,
            {
              alarm_name        = "${split("/", alarm.namespace)[1]}-${alarm.alarm_name}-${instance_id}"
              alarm_description = try(alarm.alarm_description, "RDS Instance [${instance_id}]")
              dimensions = {
                DBInstanceIdentifier = instance_id
              }
            }
          )
        } if startswith(alarm_name, "${cluster_name}-")
      ]
    ] if can(var.rds_aurora_parameters) && var.rds_aurora_parameters != {} && try(cluster_config.enable_alarms, var.rds_aurora_defaults.enable_alarms, false)
  ])...)
}

/*----------------------------------------------------------------------*/
/* SNS Alarms Variables                                                 */
/*----------------------------------------------------------------------*/

locals {
  enable_alarms_sns_default = anytrue([
    for _, alarm_value in local.alarms :
    length(alarm_value.ok_actions) == 0 || length(alarm_value.alarm_actions) == 0
  ]) ? 1 : 0
}

data "aws_sns_topic" "alarms_sns_topic_name" {
  count = local.enable_alarms_sns_default
  name  = local.default_sns_topic_name
}

/*----------------------------------------------------------------------*/
/* CW Alarms Variables                                                  */
/*----------------------------------------------------------------------*/

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = nonsensitive(local.alarms_for_cluster)

  alarm_name          = each.value.alarm_name
  alarm_description   = each.value.alarm_description
  actions_enabled     = each.value.actions_enabled
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold           = each.value.threshold
  period              = each.value.period
  unit                = each.value.unit
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  statistic           = each.value.statistic
  extended_statistic  = each.value.extended_statistic
  dimensions          = each.value.dimensions
  treat_missing_data  = each.value.treat_missing_data

  alarm_actions = length(each.value.alarm_actions) == 0 ? [data.aws_sns_topic.alarms_sns_topic_name[0].arn] : each.value.alarm_actions
  ok_actions    = length(each.value.ok_actions) == 0 ? [data.aws_sns_topic.alarms_sns_topic_name[0].arn] : each.value.ok_actions

  # conflicts with metric_name
  dynamic "metric_query" {
    for_each = try(each.value.metric_query, var.rds_aurora_defaults.alarms_defaults.metric_query, [])
    content {
      id          = lookup(metric_query.value, "id")
      account_id  = lookup(metric_query.value, "account_id", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      expression  = lookup(metric_query.value, "expression", null)
      period      = lookup(metric_query.value, "period", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }
  threshold_metric_id = try(each.value.threshold_metric_id, var.rds_aurora_defaults.alarms_defaults.threshold_metric_id, null)

  tags = merge(try(each.value.tags, {}), local.common_tags, try(each.value.alarms_tags, {}))
}