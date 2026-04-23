# ============================================================
# Projeto e Ambiente
# ============================================================

variable "project_name" {
  description = "Nome do projeto. Usado como prefixo em todos os recursos."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name deve conter apenas letras minúsculas, números e hífens."
  }
}

variable "environment" {
  description = "Nome do ambiente (ex: prod, staging)."
  type        = string

  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "environment deve ser prod, staging ou dev."
  }
}

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region deve ser uma região AWS válida (ex: us-east-1)."
  }
}

# ============================================================
# VPC Existente
# ============================================================

variable "vpc_id" {
  description = "ID da VPC existente onde os recursos serão criados."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "vpc_id deve ser um ID de VPC válido (ex: vpc-0abc123def456789a)."
  }
}

variable "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas para ECS e NLB."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Forneça pelo menos 2 subnets privadas para alta disponibilidade."
  }
}

variable "existing_iis_security_group_id" {
  description = "ID do Security Group da instância IIS existente (origem do tráfego OTLP)."
  type        = string

  validation {
    condition     = can(regex("^sg-[a-f0-9]+$", var.existing_iis_security_group_id))
    error_message = "existing_iis_security_group_id deve ser um ID de Security Group válido."
  }
}

variable "lambda_adot_security_group_ids" {
  description = "Lista de IDs dos Security Groups das Lambdas com ADOT (fontes futuras de OTLP)."
  type        = list(string)
  default     = []
}

variable "api_ec2_security_group_ids" {
  description = "Lista de IDs dos Security Groups das instâncias EC2 de API (fontes opcionais futuras)."
  type        = list(string)
  default     = []
}

variable "enable_api_otlp_ingestion" {
  description = "Habilita regras de Security Group para ingestão OTLP das instâncias EC2 de API."
  type        = bool
  default     = false
}

# ============================================================
# ECS — Capacidade
# ============================================================

variable "desired_count_frontend" {
  description = "Número desejado de tasks do otel-frontend. Use 0 para manter o service inativo."
  type        = number
  default     = 0

  validation {
    condition     = var.desired_count_frontend >= 0
    error_message = "desired_count_frontend deve ser >= 0."
  }
}

variable "desired_count_aggregator" {
  description = "Número desejado de tasks do otel-aggregator. Use 0 para manter o service inativo."
  type        = number
  default     = 0

  validation {
    condition     = var.desired_count_aggregator >= 0
    error_message = "desired_count_aggregator deve ser >= 0."
  }
}

variable "cpu_frontend" {
  description = "CPU alocada para a task do otel-frontend (unidades Fargate: 256, 512, 1024, 2048, 4096)."
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu_frontend)
    error_message = "cpu_frontend deve ser um valor válido de CPU Fargate: 256, 512, 1024, 2048 ou 4096."
  }
}

variable "memory_frontend" {
  description = "Memória alocada para a task do otel-frontend em MB."
  type        = number
  default     = 1024
}

variable "cpu_aggregator" {
  description = "CPU alocada para a task do otel-aggregator (unidades Fargate)."
  type        = number
  default     = 1024

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu_aggregator)
    error_message = "cpu_aggregator deve ser um valor válido de CPU Fargate: 256, 512, 1024, 2048 ou 4096."
  }
}

variable "memory_aggregator" {
  description = "Memória alocada para a task do otel-aggregator em MB."
  type        = number
  default     = 2048
}

# ============================================================
# Autoscaling
# ============================================================

variable "enable_autoscaling_frontend" {
  description = "Habilita autoscaling para o otel-frontend. Mantenha false na Fase 1."
  type        = bool
  default     = false
}

variable "enable_autoscaling_aggregator" {
  description = "Habilita autoscaling para o otel-aggregator. Mantenha false na Fase 1."
  type        = bool
  default     = false
}

variable "min_capacity_frontend" {
  description = "Capacidade mínima de tasks para autoscaling do otel-frontend."
  type        = number
  default     = 1
}

variable "max_capacity_frontend" {
  description = "Capacidade máxima de tasks para autoscaling do otel-frontend."
  type        = number
  default     = 4
}

variable "min_capacity_aggregator" {
  description = "Capacidade mínima de tasks para autoscaling do otel-aggregator."
  type        = number
  default     = 1
}

variable "max_capacity_aggregator" {
  description = "Capacidade máxima de tasks para autoscaling do otel-aggregator."
  type        = number
  default     = 4
}

# ============================================================
# Logs
# ============================================================

variable "log_retention_days" {
  description = "Retenção dos logs no CloudWatch em dias."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days deve ser um valor válido de retenção do CloudWatch Logs."
  }
}

# ============================================================
# Storage Futuro
# ============================================================

variable "mimir_bucket_name" {
  description = "Nome do bucket S3 para uso futuro pelo Mimir (métricas)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.mimir_bucket_name))
    error_message = "mimir_bucket_name deve ser um nome de bucket S3 válido."
  }
}

variable "tempo_bucket_name" {
  description = "Nome do bucket S3 para uso futuro pelo Tempo (traces)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.tempo_bucket_name))
    error_message = "tempo_bucket_name deve ser um nome de bucket S3 válido."
  }
}

# ============================================================
# Terraform Backend (referência para outputs e documentação)
# ============================================================

variable "terraform_state_bucket_name" {
  description = "Nome do bucket S3 que armazena o estado do Terraform (apenas para referência/documentação)."
  type        = string
}

variable "terraform_state_key" {
  description = "Chave (path) do estado Terraform no bucket S3."
  type        = string
  default     = "observability/phase1/terraform.tfstate"
}

# ============================================================
# Tags
# ============================================================

variable "tags" {
  description = "Mapa de tags aplicadas a todos os recursos via default_tags do provider."
  type        = map(string)
  default     = {}
}
