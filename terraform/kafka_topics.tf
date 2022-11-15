resource "aiven_kafka_topic" fx {
  project                = var.project
  service_name           = aiven_kafka.prod_kafka.service_name
  topic_name             = "fxrates"
  partitions             = 5
  replication            = 3
  termination_protection = false

  config {
    flush_ms                       = 10
    unclean_leader_election_enable = true
    cleanup_policy                 = "compact,delete"
  }

  timeouts {
    create = "1m"
    read   = "5m"
  }
}

resource "aiven_kafka_topic" "trade" {
  project                = var.project
  service_name           = aiven_kafka.prod_kafka.service_name
  topic_name             = "trade"
  partitions             = 5
  replication            = 3
  termination_protection = false

  config {
    flush_ms                       = 10
    unclean_leader_election_enable = true
    cleanup_policy                 = "compact,delete"
  }

  timeouts {
    create = "1m"
    read   = "5m"
  }
}

resource "aiven_kafka_topic" "quote" {
  project                = var.project
  service_name           = aiven_kafka.prod_kafka.service_name
  topic_name             = "quote"
  partitions             = 5
  replication            = 3
  termination_protection = false

  config {
    flush_ms                       = 10
    unclean_leader_election_enable = true
    cleanup_policy                 = "compact,delete"
  }

  timeouts {
    create = "1m"
    read   = "5m"
  }
}

resource "aiven_kafka_topic" "order" {
  project                = var.project
  service_name           = aiven_kafka.prod_kafka.service_name
  topic_name             = "order"
  partitions             = 5
  replication            = 3
  termination_protection = false

  config {
    flush_ms                       = 10
    unclean_leader_election_enable = true
    cleanup_policy                 = "compact,delete"
  }

  timeouts {
    create = "1m"
    read   = "5m"
  }
}

