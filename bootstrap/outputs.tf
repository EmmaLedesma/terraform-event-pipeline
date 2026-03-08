output "state_bucket_name" {
  description = "Nombre del bucket S3 para el estado remoto"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN del bucket S3 (útil para políticas IAM)"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "next_step" {
  description = "Instrucción para continuar"
  value       = "Backend listo. Ahora configurá environments/dev/main.tf con estos valores."
}