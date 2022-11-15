resource "aiven_kafka_connect" "kc" {
  project                 = var.project
  cloud_name              = var.prod_cloud_name
  plan                    = var.kafka_plan
  service_name            = "kc"
  maintenance_window_dow  = var.maint_dow
  maintenance_window_time = var.maint_time
}

resource "aiven_service_integration" "kafka_connect" {
  project                  = var.project
  integration_type         = "kafka_connect"
  source_service_name      = aiven_kafka.prod_kafka.service_name
  destination_service_name = aiven_kafka_connect.kc.service_name
}

resource "aiven_kafka_connector" "cdc" {
  project        = var.project
  service_name   = aiven_kafka_connect.kc.service_name
  connector_name = "cdc"

  config = {
    "name" = "cdc"
    "topics" = aiven_kafka_topic.order.topic_name
    "connector.class" = "io.debezium.connector.postgresql.PostgresConnector"
    "database.hostname" =  aiven_pg.pg.service_host
    "database.port" = aiven_pg.pg.service_port
    "database.password" = aiven_pg.pg.service_password
    "database.user" = aiven_pg.pg.service_username
    "database.server.name" = "pg"
    "database.dbname" = "defaultdb"
    "database.ssl.mode" = "require"
    "include.schema.changes" = false
    "include.query" = true
    "table.include.list" = "public.orders"
    "plugin.name" = "wal2json"
    "decimal.handling.mode" = "double"
    "_aiven.restart.on.failure" = "true"
    "key.converter" = "io.confluent.connect.avro.AvroConverter"
    "key.converter.schema.registry.url" = aiven_kafka.prod_kafka.kafka[0].schema_registry_uri
    "key.converter.basic.auth.credentials.source" = "URL"
    "value.converter" = "io.confluent.connect.avro.AvroConverter"
    "value.converter.schema.registry.url" = aiven_kafka.prod_kafka.kafka[0].schema_registry_uri
    "value.converter.basic.auth.credentials.source" = "URL"
  }
}

