locals {
  name_prefix = "${var.project_name}-${var.environment}"

  otel_frontend_name   = "${local.name_prefix}-otel-frontend"
  otel_aggregator_name = "${local.name_prefix}-otel-aggregator"

  # Porta padrão OTLP gRPC
  otlp_grpc_port = 4317
  # Porta padrão OTLP HTTP
  otlp_http_port = 4318

  # Imagem base do OpenTelemetry Collector Contrib
  # Atualize a tag conforme necessário antes de ativar os services
  otel_collector_image = "otel/opentelemetry-collector-contrib:0.99.0"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}
