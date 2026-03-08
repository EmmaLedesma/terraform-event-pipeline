# modules/storage/main.tf
# ─────────────────────────────────────────────────────────────
# Módulo: Storage
# Crea el bucket S3 que dispara el pipeline de eventos.
# ─────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "pipeline_input" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Module = "storage"
  })
}

# Bloquear acceso público — buena práctica siempre
resource "aws_s3_bucket_public_access_block" "pipeline_input" {
  bucket = aws_s3_bucket.pipeline_input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning opcional — controlado por variable
resource "aws_s3_bucket_versioning" "pipeline_input" {
  bucket = aws_s3_bucket.pipeline_input.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Notificación S3 → Lambda (se configura desde fuera del módulo)
# Esto permite que el módulo compute inyecte el trigger
resource "aws_s3_bucket_notification" "pipeline_trigger" {
  bucket = aws_s3_bucket.pipeline_input.id

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.trigger_prefix
    filter_suffix       = var.trigger_suffix
  }

  # La notificación depende del permiso que da Lambda
  depends_on = [var.lambda_permission_id]
}