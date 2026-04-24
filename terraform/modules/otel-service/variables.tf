variable "service_name" {
  description = "Nome completo do ECS Service."
  type        = string
}

variable "name_prefix" {
  description = "Prefixo de nomenclatura."
  type        = string
}

variable "cluster_id" {
  description = "ID do ECS Cluster."
  type        = string
}

variable "cluster_name" {
  description = "Nome do ECS Cluster (necessário para autoscaling)."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para o ECS Service."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group do ECS Service."
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
  description = "Memória alocada para a task em MB."
  type        = number
}

variable "desired_count" {
  description = "Número desejado de tasks."
  type        = number
  default     = 0
}

variable "otlp_grpc_port" {
  description = "Porta OTLP gRPC."
  type        = number
}

variable "otlp_http_port" {
  description = "Porta OTLP HTTP."
  type        = number
}

variable "log_group_name" {
  description = "Nome do CloudWatch Log Group."
  type        = string
}

variable "aws_region" {
  description = "Região AWS."
  type        = string
}

variable "container_image" {
  description = "Imagem Docker do container."
  type        = string
}

variable "command" {
  description = "Comando para executar no container."
  type        = list(string)
  default     = ["--config=env:OTEL_CONFIG"]
}

variable "collector_config" {
  description = "Conteúdo YAML da configuração do OpenTelemetry Collector."
  type        = string
}

variable "cloud_map_service_arn" {
  description = "ARN do service record no Cloud Map para service discovery. Null se nao utilizado."
  type        = string
  default     = null
}

variable "target_group_grpc_arn" {
  description = "ARN do Target Group OTLP gRPC. Null se o service não for exposto pelo NLB."
  type        = string
  default     = null
}

variable "target_group_http_arn" {
  description = "ARN do Target Group OTLP HTTP. Null se o service não for exposto pelo NLB."
  type        = string
  default     = null
}

variable "enable_autoscaling" {
  description = "Habilita autoscaling para este service."
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Capacidade mínima de tasks para autoscaling."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Capacidade máxima de tasks para autoscaling."
  type        = number
  default     = 4
}
