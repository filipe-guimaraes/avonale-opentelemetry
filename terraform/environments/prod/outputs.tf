output "ecs_cluster_id" {
  value = module.ecs_cluster.cluster_id
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "nlb_dns_name" {
  description = "DNS do NLB interno. Configure o IIS para enviar OTLP para este endereço."
  value       = module.nlb_internal.nlb_dns_name
}

output "nlb_arn" {
  value = module.nlb_internal.nlb_arn
}

output "otel_frontend_service_name" {
  value = module.otel_frontend.service_name
}

output "otel_aggregator_service_name" {
  value = module.otel_aggregator.service_name
}

output "otel_frontend_task_definition_arn" {
  value = module.otel_frontend.task_definition_arn
}

output "otel_aggregator_task_definition_arn" {
  value = module.otel_aggregator.task_definition_arn
}

output "otel_frontend_log_group_name" {
  value = module.cloudwatch.frontend_log_group_name
}

output "otel_aggregator_log_group_name" {
  value = module.cloudwatch.aggregator_log_group_name
}

output "mimir_bucket_name" {
  value = module.s3_observability.mimir_bucket_name
}

output "tempo_bucket_name" {
  value = module.s3_observability.tempo_bucket_name
}

output "security_group_frontend_id" {
  value = module.security_groups.frontend_sg_id
}

output "security_group_aggregator_id" {
  value = module.security_groups.aggregator_sg_id
}
