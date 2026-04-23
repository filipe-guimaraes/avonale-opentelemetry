output "namespace_id" {
  description = "ID do namespace DNS privado do Cloud Map."
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "namespace_hosted_zone_id" {
  description = "ID da hosted zone Route 53 associada ao namespace."
  value       = aws_service_discovery_private_dns_namespace.this.hosted_zone
}

output "aggregator_service_arn" {
  description = "ARN do service record do otel-aggregator no Cloud Map."
  value       = aws_service_discovery_service.aggregator.arn
}

output "aggregator_dns_name" {
  description = "DNS name completo do otel-aggregator."
  value       = "${var.aggregator_service_name}.${var.namespace_name}"
}

output "mimir_service_arn" {
  description = "ARN do service record do Mimir no Cloud Map."
  value       = aws_service_discovery_service.mimir.arn
}

output "mimir_dns_name" {
  description = "DNS name completo do Mimir."
  value       = "mimir.${var.namespace_name}"
}

output "tempo_service_arn" {
  description = "ARN do service record do Tempo no Cloud Map."
  value       = aws_service_discovery_service.tempo.arn
}

output "tempo_dns_name" {
  description = "DNS name completo do Tempo."
  value       = "tempo.${var.namespace_name}"
}
