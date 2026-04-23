output "cluster_id" {
  description = "ID do ECS Cluster."
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ARN do ECS Cluster."
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Nome do ECS Cluster."
  value       = aws_ecs_cluster.this.name
}
