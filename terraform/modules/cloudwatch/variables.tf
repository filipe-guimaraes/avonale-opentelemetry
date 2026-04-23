variable "otel_frontend_name" {
  description = "Nome do serviço otel-frontend."
  type        = string
}

variable "otel_aggregator_name" {
  description = "Nome do serviço otel-aggregator."
  type        = string
}

variable "mimir_name" {
  description = "Nome do servico Mimir."
  type        = string
}

variable "tempo_name" {
  description = "Nome do servico Tempo."
  type        = string
}

variable "log_retention_days" {
  description = "Retenção dos logs em dias."
  type        = number
}
