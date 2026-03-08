# modules/messaging/main.tf
# ─────────────────────────────────────────────────────────────
# Módulo: Messaging
# Crea la cola SQS y el topic SNS que reciben
# los eventos procesados por la Lambda.
# ─────────────────────────────────────────────────────────────

# ── SQS Queue — recibe mensajes de la Lambda ────────────────
resource "aws_sqs_queue" "pipeline_queue" {
  name                       = "${var.project_name}-${var.environment}-queue"
  delay_seconds              = 0
  max_message_size           = 262144  # 256 KB máximo
  message_retention_seconds  = 86400   # 1 día
  visibility_timeout_seconds = 30

  tags = merge(var.tags, {
    Module = "messaging"
  })
}

# ── SQS Policy — permite que Lambda envíe mensajes ──────────
resource "aws_sqs_queue_policy" "pipeline_queue" {
  queue_url = aws_sqs_queue.pipeline_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowLambdaSendMessage"
        Effect    = "Allow"
        Principal = { AWS = var.lambda_role_arn }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.pipeline_queue.arn
      }
    ]
  })
}

# ── SNS Topic — notificaciones del pipeline ─────────────────
resource "aws_sns_topic" "pipeline_notifications" {
  name = "${var.project_name}-${var.environment}-notifications"

  tags = merge(var.tags, {
    Module = "messaging"
  })
}

# ── SNS Subscription — email para recibir notificaciones ────
resource "aws_sns_topic_subscription" "email_alert" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}