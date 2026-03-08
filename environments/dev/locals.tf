# environments/dev/locals.tf
# ─────────────────────────────────────────────────────────────
# Locals: valores calculados y reutilizables en este environment.
# Centralizan el naming convention del proyecto.
# ─────────────────────────────────────────────────────────────

locals {
  project_name = "event-pipeline"
  environment  = "dev"

  # Naming convention: proyecto-ambiente-recurso
  bucket_name = "${local.project_name}-${local.environment}-input-${var.aws_account_id}"

  # Tags aplicados a todos los recursos del environment
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = "emmanuel-ledesma"
    Repository  = "github.com/EmmaLedesma/terraform-event-pipeline"
  }
}