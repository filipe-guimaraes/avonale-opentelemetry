variable "name_prefix" {
  description = "Prefixo de nomenclatura."
  type        = string
}

variable "mimir_bucket_name" {
  description = "Nome do bucket S3 para o Mimir."
  type        = string
}

variable "tempo_bucket_name" {
  description = "Nome do bucket S3 para o Tempo."
  type        = string
}
