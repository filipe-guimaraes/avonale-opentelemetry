output "service_name" {
  description = "Nome do ECS Service."
  value       = aws_ecs_service.this.name
}

output "service_id" {
  description = "ID do ECS Service."
  value       = aws_ecs_service.this.id
}

output "task_definition_arn" {
  description = "ARN da Task Definition."
  value       = aws_ecs_task_definition.this.arn
}
