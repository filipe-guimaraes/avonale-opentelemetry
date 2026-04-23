# ============================================================
# Projeto e Ambiente
# ============================================================

variable "project_name" {
  description = "Nome do projeto."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente."
  type        = string
}

variable "aws_region" {
  description = "Região AWS."
  type        = string
}

# ============================================================
# VPC Existente
# ============================================================

variable "vpc_id" {
  description = "ID da VPC existente."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas."
  type        = list(string)
}

variable "existing_iis_security_group_id" {
  description = "ID do Security Group da instância IIS."
  type        = string
}

variable "lambda_adot_security_group_ids" {
  description = "IDs dos Security Groups das Lambdas ADOT."
  type        = list(string)
  default     = []
}

variable "api_ec2_security_group_ids" {
  description = "IDs dos Security Groups das EC2 de API."
  type        = list(string)
  default     = []
}

variable "enable_api_otlp_ingestion" {
  description = "Habilita regras de SG para EC2 de API."
  type        = bool
  default     = false
}

# ============================================================
# ECS
# ============================================================

variable "desired_count_frontend" {
  type    = number
  default = 0
}

variable "desired_count_aggregator" {
  type    = number
  default = 0
}

variable "cpu_frontend" {
  type    = number
  default = 512
}

variable "memory_frontend" {
  type    = number
  default = 1024
}

variable "cpu_aggregator" {
  type    = number
  default = 1024
}

variable "memory_aggregator" {
  type    = number
  default = 2048
}

# ============================================================
# Autoscaling
# ============================================================

variable "enable_autoscaling_frontend" {
  type    = bool
  default = false
}

variable "enable_autoscaling_aggregator" {
  type    = bool
  default = false
}

variable "min_capacity_frontend" {
  type    = number
  default = 1
}

variable "max_capacity_frontend" {
  type    = number
  default = 4
}

variable "min_capacity_aggregator" {
  type    = number
  default = 1
}

variable "max_capacity_aggregator" {
  type    = number
  default = 4
}

# ============================================================
# Logs
# ============================================================

variable "log_retention_days" {
  type    = number
  default = 30
}

# ============================================================
# Storage
# ============================================================

variable "mimir_bucket_name" {
  type = string
}

variable "tempo_bucket_name" {
  type = string
}

variable "terraform_state_bucket_name" {
  type = string
}

variable "terraform_state_key" {
  type    = string
  default = "observability/phase1/prod/terraform.tfstate"
}

# ============================================================
# Tags
# ============================================================

variable "tags" {
  type    = map(string)
  default = {}
}
