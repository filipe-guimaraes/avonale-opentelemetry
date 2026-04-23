variable "name_prefix" {
  description = "Prefixo de nomenclatura."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para o NLB."
  type        = list(string)
}

variable "nlb_sg_id" {
  description = "ID do Security Group do NLB."
  type        = string
}

variable "otlp_grpc_port" {
  description = "Porta OTLP gRPC."
  type        = number
}

variable "otlp_http_port" {
  description = "Porta OTLP HTTP."
  type        = number
}
