# modules/storage/outputs.tf

output "bucket_id" {
  description = "ID del bucket S3 (mismo que el nombre)"
  value       = aws_s3_bucket.pipeline_input.id
}

output "bucket_arn" {
  description = "ARN del bucket — usado en políticas IAM de Lambda"
  value       = aws_s3_bucket.pipeline_input.arn
}

output "bucket_name" {
  description = "Nombre del bucket para mostrar en outputs del environment"
  value       = aws_s3_bucket.pipeline_input.bucket
}