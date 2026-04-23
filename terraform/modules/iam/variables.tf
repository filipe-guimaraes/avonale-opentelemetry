variable "name_prefix" {
  description = "Prefixo de nomenclatura dos recursos."
  type        = string
}

variable "mimir_name" {
  description = "Nome completo do servico Mimir."
  type        = string
}

variable "tempo_name" {
  description = "Nome completo do servico Tempo."
  type        = string
}

variable "mimir_bucket_name" {
  description = "Nome do bucket S3 do Mimir."
  type        = string
}

variable "tempo_bucket_name" {
  description = "Nome do bucket S3 do Tempo."
  type        = string
}

variable "otel_frontend_name" {
  description = "Nome completo do serviço otel-frontend."
  type        = string
}

variable "otel_aggregator_name" {
  description = "Nome completo do serviço otel-aggregator."
  type        = string
}

variable "aws_region" {
  description = "Região AWS."
  type        = string
}

variable "account_id" {
  description = "ID da conta AWS."
  type        = string
}
