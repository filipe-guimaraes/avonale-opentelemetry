resource "aws_cloudwatch_log_group" "otel_frontend" {
  name              = "/ecs/${var.otel_frontend_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name    = "/ecs/${var.otel_frontend_name}"
    Service = "otel-frontend"
  }
}

resource "aws_cloudwatch_log_group" "otel_aggregator" {
  name              = "/ecs/${var.otel_aggregator_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name    = "/ecs/${var.otel_aggregator_name}"
    Service = "otel-aggregator"
  }
}

resource "aws_cloudwatch_log_group" "mimir" {
  name              = "/ecs/${var.mimir_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name    = "/ecs/${var.mimir_name}"
    Service = "mimir"
  }
}

resource "aws_cloudwatch_log_group" "tempo" {
  name              = "/ecs/${var.tempo_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name    = "/ecs/${var.tempo_name}"
    Service = "tempo"
  }
}
