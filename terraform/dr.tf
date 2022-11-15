resource "aiven_service_integration" "pg_dr" {
  project                  = var.project
  integration_type         = "read_replica"
  source_service_name      = aiven_pg.pg.service_name
  destination_service_name = aiven_pg.pg_dr.service_name
}

resource "aiven_service_integration" "mm2-prod" {
  project                  = var.project
  integration_type         = "kafka_mirrormaker"
  source_service_name      = aiven_kafka.prod_kafka.service_name
  destination_service_name = aiven_kafka_mirrormaker.mm2.service_name
  kafka_mirrormaker_user_config {
    cluster_alias = "prod"
  }
}

resource "aiven_service_integration" "mm2-dr" {
  project                  = var.project
  integration_type         = "kafka_mirrormaker"
  source_service_name      = aiven_kafka.dr_kafka.service_name
  destination_service_name = aiven_kafka_mirrormaker.mm2.service_name
  kafka_mirrormaker_user_config {
    cluster_alias = "dr"
  }
}

resource "aiven_mirrormaker_replication_flow" "dr-replication-flow" {
  project                    = var.project
  service_name               = aiven_kafka_mirrormaker.mm2.service_name
  source_cluster             = "prod"
  target_cluster             = "dr"
  replication_policy_class   = "org.apache.kafka.connect.mirror.IdentityReplicationPolicy"
  sync_group_offsets_enabled = true
  emit_heartbeats_enabled    = true
  enable                     = true

  topics = [
    ".*"
  ]
}


resource "aiven_pg" "pg_dr" {
  project                 = var.project
  cloud_name              = var.dr_cloud_name
  plan                    = var.dr_pg_plan
  service_name            = "dr-pg"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  pg_user_config {
    pg_version = 14
  }

  timeouts {
    create = "20m"
    update = "15m"
  }

  service_integrations {
    integration_type = "read_replica"
    source_service_name = aiven_pg.pg.service_name
  }
}

resource "aiven_kafka_mirrormaker" "mm2" {
  project      = var.project
  cloud_name   = var.prod_cloud_name
  plan         = var.kafka_plan
  service_name = "mm2"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  kafka_mirrormaker_user_config {

    kafka_mirrormaker {
      refresh_groups_interval_seconds = 600
      refresh_topics_enabled          = true
      refresh_topics_interval_seconds = 600
    }
  }
}

resource "aiven_kafka" "dr_kafka" {
  project      = var.project
  cloud_name   = var.dr_cloud_name
  plan         = var.kafka_plan
  service_name = "dr-kafka"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  kafka_user_config {
    kafka_connect   = true
    kafka_rest      = true
    schema_registry = true
    kafka_version   = var.kafka_version
    kafka {
      auto_create_topics_enable = true
    }
  }


}

resource "aiven_clickhouse" "dr_clickhouse" {
  project      = var.project
  cloud_name   = var.prod_cloud_name
  plan         = var.clickhouse_plan
  service_name = "dr-clickhouse"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

}

output "dr_kafka_service_name" {
  value = aiven_kafka.dr_kafka.service_name
}