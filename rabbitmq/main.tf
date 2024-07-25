locals {
  mq_application_user_needed = length(var.mq_application_user) == 0
  mq_application_user        = local.mq_application_user_needed ? random_pet.mq_application_user[0].id : try(var.mq_application_user[0], "")

  mq_application_password_needed = length(var.mq_application_password) == 0
  mq_application_password        = local.mq_application_password_needed ? random_password.mq_application_password[0].result : try(var.mq_application_password[0], "")

  mq_logs = { logs = { "general_log_enabled" : var.general_log_enabled, "audit_log_enabled" : var.audit_log_enabled } }

}

resource "random_pet" "mq_application_user" {
  count     = local.mq_application_user_needed ? 1 : 0
  length    = 2
  separator = "-"
}

resource "random_password" "mq_application_password" {
  count   = local.mq_application_password_needed ? 1 : 0
  length  = 24
  special = false
}

resource "aws_mq_broker" "main" {
  broker_name                = var.name
  deployment_mode            = var.deployment_mode
  engine_type                = var.engine_type
  engine_version             = var.engine_version
  host_instance_type         = var.host_instance_type
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  publicly_accessible        = var.publicly_accessible
  subnet_ids                 = var.subnet_ids

  tags = {
    Name = var.name
  }

  security_groups = var.broker_security_groups

  # NOTE: Omit logs block if both general and audit logs disabled:
  # https://github.com/hashicorp/terraform-provider-aws/issues/18067
  dynamic "logs" {
    for_each = {
      for logs, type in local.mq_logs : logs => type
      if type.general_log_enabled || type.audit_log_enabled
    }
    content {
      general = logs.value["general_log_enabled"]
      audit   = logs.value["audit_log_enabled"]
    }
  }

  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week
    time_of_day = var.maintenance_time_of_day
    time_zone   = var.maintenance_time_zone
  }

  user {
    username = local.mq_application_user
    password = local.mq_application_password
  }
}

resource "aws_cloudwatch_log_group" "general_logs" {
  count = var.general_log_enabled ? 1 : 0

  name              = "/aws/amazonmq/broker/${aws_mq_broker.main.id}/general"
  retention_in_days = var.log_retention_in_days

  tags = {
    Name = "${var.name}-general-log-group"
  }
}
