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

output "task_definition_family" {
  description = "Family da Task Definition."
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "Revisão atual da Task Definition."
  value       = aws_ecs_task_definition.this.revision
}
