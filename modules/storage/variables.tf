# modules/storage/variables.tf

variable "bucket_name" {
  description = "Nombre único global del bucket S3"
  type        = string
}

variable "enable_versioning" {
  description = "Habilitar versioning en el bucket"
  type        = bool
  default     = false
}

variable "lambda_arn" {
  description = "ARN de la Lambda que procesa los eventos S3"
  type        = string
}

variable "lambda_permission_id" {
  description = "ID del permiso Lambda (para depends_on implícito)"
  type        = string
}

variable "trigger_prefix" {
  description = "Prefijo de objetos que disparan la Lambda (ej: 'uploads/')"
  type        = string
  default     = ""
}

variable "trigger_suffix" {
  description = "Sufijo de objetos que disparan la Lambda (ej: '.json')"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
  default     = {}
}