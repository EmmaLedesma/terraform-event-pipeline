# modules/compute/outputs.tf

output "lambda_arn" {
  description = "ARN de la Lambda — usado por el módulo storage para el trigger"
  value       = aws_lambda_function.processor.arn
}

output "lambda_name" {
  description = "Nombre de la Lambda"
  value       = aws_lambda_function.processor.function_name
}

output "lambda_role_arn" {
  description = "ARN del IAM Role — usado por el módulo messaging para la política SQS"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_permission_id" {
  description = "ID del permiso S3→Lambda — usado como depends_on en módulo storage"
  value       = aws_lambda_permission.allow_s3.id
}