terraform {
  required_providers {
    aiven = {
      source  = "aiven/aiven"
      version = "3.8.0"
    }
  }
}

provider "aiven" {
  api_token = var.aiven_api_token
}


module "metrics-logs-prod" {
  source = "./modules/metrics-logs"
  svcs = [
    aiven_kafka.prod_kafka.service_name,
    aiven_kafka_connect.kc.service_name,
    aiven_pg.pg.service_name,
    # aiven_clickhouse.prod_clickhouse.service_name,
    aiven_flink.flink.service_name
  ]
  project    = var.project
  cloud_name = var.prod_cloud_name
  maint_dow = var.maint_dow
  maint_time = var.maint_time
  prefix     = "prod"
  os_log_integration_plan = var.os_log_integration_plan
  m3db_metrics_integration_plan = var.m3db_metrics_integration_plan
  grafana_integration_plan = var.grafana_integration_plan
}

module "metrics-logs-dr" {
  source = "./modules/metrics-logs"
  svcs = [
    aiven_kafka.dr_kafka.service_name,
    aiven_pg.pg_dr.service_name
    # aiven_clickhouse.dr_clickhouse.service_name
  ]
  project    = var.project
  cloud_name = var.dr_cloud_name
  prefix     = "dr"
  maint_dow = var.maint_dow
  maint_time = var.maint_time
  os_log_integration_plan = var.os_log_integration_plan
  m3db_metrics_integration_plan = var.m3db_metrics_integration_plan
  grafana_integration_plan = var.grafana_integration_plan
}