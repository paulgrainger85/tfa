resource "aiven_service_integration" "flink_kafka" {
  project                  = var.project
  integration_type         = "flink"
  source_service_name      = aiven_kafka.prod_kafka.service_name
  destination_service_name = aiven_flink.flink.service_name
}

resource "aiven_service_integration" "flink_pg" {
  project                  = var.project
  integration_type         = "flink"
  source_service_name      = aiven_pg.pg.service_name
  destination_service_name = aiven_flink.flink.service_name
}


resource "aiven_flink_table" "order" {
  project        = var.project
  service_name   = aiven_flink.flink.service_name
  table_name     = "orders"
  integration_id = aiven_service_integration.flink_kafka.integration_id

  # valid if the service integration refers to a kafka service
  kafka_topic = aiven_kafka_topic.order.topic_name

  schema_sql = <<EOF
      `sym` TEXT,
      `orderid` GUID,
      `time` TIMESTAMP,
      `clientid` INT,
      `price` FLOAT,
      `qty` INT,
      `side` CHAR(1)
    EOF
}

resource "aiven_flink_table" "ref" {
  project        = var.project
  service_name   = aiven_flink.flink.service_name
  table_name     = "ref"
  integration_id = aiven_service_integration.flink_pg.integration_id

  # valid if the service integration refers to a postgres or mysql service
  jdbc_table = "refdata"

  schema_sql = <<EOF
      `sym` TEXT,
      `ccy` TEXT
    EOF
}


resource "aiven_flink_table" "fxrates" {
  project        = var.project
  service_name   = aiven_flink.flink.service_name
  table_name     = "fxrates"
  integration_id = aiven_service_integration.flink_kafka.integration_id

  # valid if the service integration refers to a kafka service
  kafka_topic = aiven_kafka_topic.fx.topic_name

  schema_sql = <<EOF
      `sym` VARCHAR,
      `rate` FLOAT,
      `time` TIMESTAMP
    EOF
}

resource "aiven_flink_table" "trade" {
  project        = var.project
  service_name   = aiven_flink.flink.service_name
  table_name     = "trade"
  integration_id = aiven_service_integration.flink_kafka.integration_id

  # valid if the service integration refers to a kafka service
  kafka_topic = aiven_kafka_topic.trade.topic_name

  schema_sql = <<EOF
      `sym` VARCHAR,
      `time` TIMESTAMP,
      `price` FLOAT,
      `qty` INT,
      `side` CHAR(1)
    EOF
}

resource "aiven_flink_table" "quote" {
  project        = var.project
  service_name   = aiven_flink.flink.service_name
  table_name     = "quote"
  integration_id = aiven_service_integration.flink_kafka.integration_id

  # valid if the service integration refers to a kafka service
  kafka_topic = aiven_kafka_topic.quote.topic_name

  schema_sql = <<EOF
      `sym` VARCHAR,
      `time` TIMESTAMP,
      `bid1` FLOAT,
      `ask1` FLOAT,
      `bid2` FLOAT,
      `ask2` FLOAT,
      `bid3` FLOAT,
      `ask3` FLOAT,
      `bidsize1` INT,
      `asksize1` INT,
      `bidsize2` INT,
      `asksize2` INT,
      `bidsize3` INT,
      `asksize3` INT,
      `qty` INT,
      `side` CHAR(1)
    EOF
}

