# environments/dev/main.tf
# ─────────────────────────────────────────────────────────────
# Environment: dev
# Ensambla los módulos compute, messaging y storage.
# El orden de declaración importa — compute primero porque
# storage y messaging necesitan sus outputs.
# ─────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── Remote backend — estado guardado en S3 ────────────────
  backend "s3" {
    bucket         = "tf-state-emmanuel-ledesma-2026"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
    profile        = "terraform-pipeline"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-pipeline"
}

# ── Módulo 1: Compute (Lambda + IAM) ────────────────────────
# Se crea primero porque storage y messaging necesitan
# sus outputs (lambda_arn, lambda_role_arn)
module "compute" {
  source = "../../modules/compute"

  project_name      = local.project_name
  environment       = local.environment
  sqs_queue_url     = module.messaging.sqs_queue_url
  sqs_queue_arn     = module.messaging.sqs_queue_arn
  sns_topic_arn     = module.messaging.sns_topic_arn
  source_bucket_arn = module.storage.bucket_arn
  tags              = local.common_tags
}

# ── Módulo 2: Messaging (SQS + SNS) ─────────────────────────
module "messaging" {
  source = "../../modules/messaging"

  project_name       = local.project_name
  environment        = local.environment
  lambda_role_arn    = module.compute.lambda_role_arn
  notification_email = var.notification_email
  tags               = local.common_tags
}

# ── Módulo 3: Storage (S3 + trigger) ────────────────────────
# Se declara último porque necesita el lambda_arn
# y el lambda_permission_id del módulo compute
module "storage" {
  source = "../../modules/storage"

  bucket_name          = local.bucket_name
  enable_versioning    = var.enable_versioning
  lambda_arn           = module.compute.lambda_arn
  lambda_permission_id = module.compute.lambda_permission_id
  trigger_prefix       = var.trigger_prefix
  trigger_suffix       = var.trigger_suffix
  tags                 = local.common_tags
}