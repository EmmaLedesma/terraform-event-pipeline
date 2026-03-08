# environments/dev/variables.tf

variable "aws_account_id" {
  description = "AWS Account ID — usado para garantizar nombre de bucket único"
  type        = string
}

variable "notification_email" {
  description = "Email para notificaciones SNS (vacío = sin suscripción)"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Habilitar versioning en el bucket S3 de input"
  type        = bool
  default     = false
}

variable "trigger_prefix" {
  description = "Prefijo S3 que dispara la Lambda (ej: 'uploads/')"
  type        = string
  default     = ""
}

variable "trigger_suffix" {
  description = "Sufijo S3 que dispara la Lambda (ej: '.json')"
  type        = string
  default     = ""
}