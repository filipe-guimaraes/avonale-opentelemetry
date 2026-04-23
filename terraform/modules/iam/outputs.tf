output "ecs_task_execution_role_arn" {
  description = "ARN da ECS Task Execution Role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Nome da ECS Task Execution Role."
  value       = aws_iam_role.ecs_task_execution.name
}

output "otel_frontend_task_role_arn" {
  description = "ARN da Task Role do otel-frontend."
  value       = aws_iam_role.otel_frontend_task.arn
}

output "otel_aggregator_task_role_arn" {
  description = "ARN da Task Role do otel-aggregator."
  value       = aws_iam_role.otel_aggregator_task.arn
}

output "mimir_task_role_arn" {
  description = "ARN da Task Role do Mimir."
  value       = aws_iam_role.mimir_task.arn
}

output "tempo_task_role_arn" {
  description = "ARN da Task Role do Tempo."
  value       = aws_iam_role.tempo_task.arn
}
