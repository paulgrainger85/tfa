variable svcs {}
variable "project" {}
variable "cloud_name" {}
variable "maint_dow" {}
variable "maint_time" {}
variable "prefix" {}
variable "os_log_integration_plan" {}
variable "grafana_integration_plan" {}
variable "m3db_metrics_integration_plan" {}
variable "m3db_version" {
    default = "1.5"
}


