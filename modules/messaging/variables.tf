# modules/messaging/variables.tf

variable "project_name" {
  description = "Nombre del proyecto — usado en el naming de recursos"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev, staging, prod"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN del IAM Role de Lambda — para la política SQS"
  type        = string
}

variable "notification_email" {
  description = "Email para recibir notificaciones SNS (vacío = sin suscripción)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
  default     = {}
}