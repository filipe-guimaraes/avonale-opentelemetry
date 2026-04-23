variable "namespace_name" {
  description = "Nome do namespace DNS privado do Cloud Map (ex: observability.local)."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o namespace DNS privado sera criado."
  type        = string
}

variable "aggregator_service_name" {
  description = "Nome do service record do otel-aggregator no Cloud Map."
  type        = string
}
