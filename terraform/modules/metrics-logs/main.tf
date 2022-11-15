terraform {
  required_providers {
    aiven = {
      source  = "aiven/aiven"
      version = "3.8.0"
    }
  }
}

resource "aiven_opensearch" "os" {
  project                 = var.project
  cloud_name              = var.cloud_name
  plan                    = var.os_log_integration_plan
  service_name            = "${var.prefix}-os-logs"
  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time
}

resource "aiven_grafana" "gr" {
  project                 = var.project
  cloud_name              = var.cloud_name
  plan                    = var.grafana_integration_plan
  service_name            = "${var.prefix}-metrics-dashboard"
  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  grafana_user_config {
    alerting_enabled = true

    public_access {
      grafana = true
    }
  }
}

resource "aiven_m3db" "metrics" {
  project                 = var.project
  cloud_name              = var.cloud_name
  plan                    = var.m3db_metrics_integration_plan
  service_name            = "${var.prefix}-m3db-metrics"
  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time

  m3db_user_config {
    m3db_version = var.m3db_version

    namespaces {
      name = "metrics_ns"
      type = "unaggregated"
    }
  }
}

resource "aiven_service_integration" "logging" {
  for_each                 = toset(var.svcs)
  project                  = var.project
  source_service_name      = each.key
  integration_type         = "logs"
  destination_service_name = aiven_opensearch.os.service_name

  logs_user_config {
    elasticsearch_index_days_max = "3"
    elasticsearch_index_prefix   = "logs"
  }
}


resource "aiven_service_integration" "metrics" {
  for_each                 = toset(var.svcs)
  project                  = var.project
  destination_service_name = aiven_m3db.metrics.service_name
  integration_type         = "metrics"
  source_service_name      = each.key
}


resource "aiven_service_integration" "metricsdash" {
  project                  = var.project
  source_service_name      = aiven_grafana.gr.service_name
  integration_type         = "dashboard"
  destination_service_name = aiven_m3db.metrics.service_name
}
