output "vpc_id" {
  description = "ID da VPC."
  value       = data.aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block da VPC."
  value       = data.aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas validadas."
  value       = [for s in data.aws_subnet.private : s.id]
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks das subnets privadas."
  value       = [for s in data.aws_subnet.private : s.cidr_block]
}

output "account_id" {
  description = "ID da conta AWS."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Região AWS atual."
  value       = data.aws_region.current.name
}
