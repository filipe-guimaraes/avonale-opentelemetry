output "ecs_cluster_id" {
  description = "ID do ECS Cluster criado."
  value       = module.ecs_cluster.cluster_id
}

output "ecs_cluster_name" {
  description = "Nome do ECS Cluster criado."
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN do ECS Cluster criado."
  value       = module.ecs_cluster.cluster_arn
}

output "nlb_arn" {
  description = "ARN do NLB interno criado."
  value       = module.nlb_internal.nlb_arn
}

output "nlb_dns_name" {
  description = "DNS name do NLB interno. Use este endereço para configurar o IIS como destino OTLP."
  value       = module.nlb_internal.nlb_dns_name
}

output "nlb_zone_id" {
  description = "Zone ID do NLB interno (útil para Route53 alias records)."
  value       = module.nlb_internal.nlb_zone_id
}

output "otel_frontend_service_name" {
  description = "Nome do ECS Service do otel-frontend."
  value       = module.otel_frontend.service_name
}

output "otel_aggregator_service_name" {
  description = "Nome do ECS Service do otel-aggregator."
  value       = module.otel_aggregator.service_name
}

output "otel_frontend_task_definition_arn" {
  description = "ARN da Task Definition do otel-frontend."
  value       = module.otel_frontend.task_definition_arn
}

output "otel_aggregator_task_definition_arn" {
  description = "ARN da Task Definition do otel-aggregator."
  value       = module.otel_aggregator.task_definition_arn
}

output "otel_frontend_log_group_name" {
  description = "Nome do CloudWatch Log Group do otel-frontend."
  value       = module.cloudwatch.frontend_log_group_name
}

output "otel_aggregator_log_group_name" {
  description = "Nome do CloudWatch Log Group do otel-aggregator."
  value       = module.cloudwatch.aggregator_log_group_name
}

output "mimir_bucket_name" {
  description = "Nome do bucket S3 reservado para o Mimir (uso futuro)."
  value       = module.s3_observability.mimir_bucket_name
}

output "tempo_bucket_name" {
  description = "Nome do bucket S3 reservado para o Tempo (uso futuro)."
  value       = module.s3_observability.tempo_bucket_name
}

output "security_group_frontend_id" {
  description = "ID do Security Group do otel-frontend."
  value       = module.security_groups.frontend_sg_id
}

output "security_group_aggregator_id" {
  description = "ID do Security Group do otel-aggregator."
  value       = module.security_groups.aggregator_sg_id
}

output "security_group_nlb_id" {
  description = "ID do Security Group do NLB interno."
  value       = module.security_groups.nlb_sg_id
}
