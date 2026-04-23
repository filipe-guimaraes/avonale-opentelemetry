variable "name_prefix" {
  description = "Prefixo de nomenclatura."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
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

variable "existing_iis_security_group_id" {
  description = "ID do SG da instância IIS."
  type        = string
}

variable "lambda_adot_security_group_ids" {
  description = "IDs dos SGs das Lambdas ADOT."
  type        = list(string)
  default     = []
}

variable "api_ec2_security_group_ids" {
  description = "IDs dos SGs das EC2 de API."
  type        = list(string)
  default     = []
}

variable "enable_api_otlp_ingestion" {
  description = "Habilita regras de SG para EC2 de API."
  type        = bool
  default     = false
}
