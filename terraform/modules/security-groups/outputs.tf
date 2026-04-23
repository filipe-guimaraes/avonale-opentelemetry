output "nlb_sg_id" {
  description = "ID do Security Group do NLB."
  value       = aws_security_group.nlb.id
}

output "frontend_sg_id" {
  description = "ID do Security Group do otel-frontend."
  value       = aws_security_group.otel_frontend.id
}

output "aggregator_sg_id" {
  description = "ID do Security Group do otel-aggregator."
  value       = aws_security_group.otel_aggregator.id
}

output "mimir_sg_id" {
  description = "ID do Security Group do Mimir."
  value       = aws_security_group.mimir.id
}

output "tempo_sg_id" {
  description = "ID do Security Group do Tempo."
  value       = aws_security_group.tempo.id
}
