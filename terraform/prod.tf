resource "aiven_pg" "pg" {
  project                 = var.project
  cloud_name              = var.prod_cloud_name
  plan                    = var.prod_pg_plan
  service_name            = "prod-pg"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  pg_user_config {
    pg_version = 14
  }

  timeouts {
    create = "20m"
    update = "15m"
  }
}


resource "aiven_kafka" "prod_kafka" {
  project      = var.project
  cloud_name   = var.prod_cloud_name
  plan         = var.kafka_plan
  service_name = "prod-kafka"

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

resource "aiven_clickhouse" "prod_clickhouse" {
  project      = var.project
  cloud_name   = var.prod_cloud_name
  plan         = var.clickhouse_plan
  service_name = "prod-clickhouse"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

}

resource "aiven_flink" "flink" {
  project      = var.project
  cloud_name   = var.prod_cloud_name
  plan         = var.flink_plan
  service_name = "prod-flink"

  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  flink_user_config {
    flink_version = var.flink_version
  }
}

output "flink_service_name" {
  value = aiven_flink.flink.service_name
}

output "prod_kafka_service_name" {
  value = aiven_kafka.prod_kafka.service_name
}

output "prod_clickhouse_service_name" {
  value = aiven_clickhouse.prod_clickhouse.service_name
}