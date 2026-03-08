# environments/dev/outputs.tf

output "bucket_name" {
  description = "Nombre del bucket S3 que dispara el pipeline"
  value       = module.storage.bucket_name
}

output "lambda_name" {
  description = "Nombre de la Lambda procesadora"
  value       = module.compute.lambda_name
}

output "sqs_queue_url" {
  description = "URL de la cola SQS"
  value       = module.messaging.sqs_queue_url
}

output "sns_topic_arn" {
  description = "ARN del topic SNS"
  value       = module.messaging.sns_topic_arn
}

output "test_command" {
  description = "Comando para probar el pipeline subiendo un archivo"
  value       = "aws s3 cp test.json s3://${module.storage.bucket_name}/ --profile terraform-pipeline"
}