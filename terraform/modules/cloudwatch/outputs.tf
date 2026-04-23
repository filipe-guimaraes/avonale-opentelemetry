output "frontend_log_group_name" {
  description = "Nome do Log Group do otel-frontend."
  value       = aws_cloudwatch_log_group.otel_frontend.name
}

output "frontend_log_group_arn" {
  description = "ARN do Log Group do otel-frontend."
  value       = aws_cloudwatch_log_group.otel_frontend.arn
}

output "aggregator_log_group_name" {
  description = "Nome do Log Group do otel-aggregator."
  value       = aws_cloudwatch_log_group.otel_aggregator.name
}

output "aggregator_log_group_arn" {
  description = "ARN do Log Group do otel-aggregator."
  value       = aws_cloudwatch_log_group.otel_aggregator.arn
}

output "mimir_log_group_name" {
  description = "Nome do Log Group do Mimir."
  value       = aws_cloudwatch_log_group.mimir.name
}

output "tempo_log_group_name" {
  description = "Nome do Log Group do Tempo."
  value       = aws_cloudwatch_log_group.tempo.name
}
