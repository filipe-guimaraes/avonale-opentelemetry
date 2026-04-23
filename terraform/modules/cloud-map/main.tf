resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.namespace_name
  description = "Namespace DNS privado para service discovery dos collectors OpenTelemetry."
  vpc         = var.vpc_id

  tags = {
    Name = var.namespace_name
  }
}

resource "aws_service_discovery_service" "aggregator" {
  name = var.aggregator_service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = var.aggregator_service_name
  }
}

resource "aws_service_discovery_service" "mimir" {
  name = "mimir"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "mimir"
  }
}

resource "aws_service_discovery_service" "tempo" {
  name = "tempo"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "tempo"
  }
}
