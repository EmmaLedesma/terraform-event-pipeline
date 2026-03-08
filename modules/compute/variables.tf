# modules/compute/variables.tf

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev, staging, prod"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL de la cola SQS — inyectada como env var a Lambda"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS — para la política IAM"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del topic SNS — inyectado como env var a Lambda"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN del bucket S3 que dispara la Lambda"
  type        = string
}

variable "tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
  default     = {}
}