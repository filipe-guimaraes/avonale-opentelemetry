output "nlb_arn" {
  description = "ARN do NLB interno."
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "DNS name do NLB interno."
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "Zone ID do NLB interno."
  value       = aws_lb.this.zone_id
}

output "target_group_grpc_arn" {
  description = "ARN do Target Group OTLP gRPC."
  value       = aws_lb_target_group.otlp_grpc.arn
}

output "target_group_http_arn" {
  description = "ARN do Target Group OTLP HTTP."
  value       = aws_lb_target_group.otlp_http.arn
}
