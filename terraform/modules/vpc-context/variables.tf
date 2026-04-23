variable "vpc_id" {
  description = "ID da VPC existente."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas."
  type        = list(string)
}
