output "mimir_bucket_name" {
  description = "Nome do bucket S3 do Mimir."
  value       = aws_s3_bucket.this["mimir"].bucket
}

output "mimir_bucket_arn" {
  description = "ARN do bucket S3 do Mimir."
  value       = aws_s3_bucket.this["mimir"].arn
}

output "tempo_bucket_name" {
  description = "Nome do bucket S3 do Tempo."
  value       = aws_s3_bucket.this["tempo"].bucket
}

output "tempo_bucket_arn" {
  description = "ARN do bucket S3 do Tempo."
  value       = aws_s3_bucket.this["tempo"].arn
}
