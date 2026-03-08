# modules/messaging/outputs.tf

output "sqs_queue_url" {
  description = "URL de la cola SQS — usada por Lambda para enviar mensajes"
  value       = aws_sqs_queue.pipeline_queue.id
}

output "sqs_queue_arn" {
  description = "ARN de la cola SQS"
  value       = aws_sqs_queue.pipeline_queue.arn
}

output "sns_topic_arn" {
  description = "ARN del topic SNS — usado por Lambda para publicar notificaciones"
  value       = aws_sns_topic.pipeline_notifications.arn
}