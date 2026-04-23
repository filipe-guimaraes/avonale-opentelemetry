variable "service_name" {
  description = "Nome completo do ECS Service."
  type        = string
}

variable "cluster_id" {
  description = "ID do ECS Cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group do service."
  type        = string
}

variable "task_execution_role" {
  description = "ARN da ECS Task Execution Role."
  type        = string
}

variable "task_role" {
  description = "ARN da ECS Task Role."
  type        = string
}

variable "cpu" {
  description = "CPU alocada para a task (unidades Fargate)."
  type        = number
}

variable "memory" {
  description = "Memoria alocada para a task em MB."
  type        = number
}

variable "desired_count" {
  description = "Numero desejado de tasks."
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Imagem Docker do container."
  type        = string
}

variable "container_command" {
  description = "Comando de inicializacao do container."
  type        = list(string)
}

variable "container_ports" {
  description = "Lista de portas expostas pelo container."
  type = list(object({
    name = string
    port = number
  }))
}

variable "backend_config" {
  description = "Conteudo YAML da configuracao do backend (Mimir ou Tempo)."
  type        = string
}

variable "log_group_name" {
  description = "Nome do CloudWatch Log Group."
  type        = string
}

variable "aws_region" {
  description = "Regiao AWS."
  type        = string
}

variable "cloud_map_service_arn" {
  description = "ARN do service record no Cloud Map."
  type        = string
}

variable "health_check_port" {
  description = "Porta para o health check HTTP."
  type        = number
}

variable "health_check_path" {
  description = "Path para o health check HTTP."
  type        = string
  default     = "/ready"
}
