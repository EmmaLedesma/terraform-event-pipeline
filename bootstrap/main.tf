terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-pipeline"   
}

# ── S3 Bucket para guardar el state remoto ──────────────────
resource "aws_s3_bucket" "terraform_state" {
  # IMPORTANTE: los bucket names son globales en AWS.
  
  bucket = "tf-state-emmanuel-ledesma-2026"

  # Protección: evita borrar el bucket con terraform destroy
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Project     = "terraform-event-pipeline"
    ManagedBy   = "terraform-bootstrap"
  }
}

# ── Versioning: guarda historial de cada state ───────────────
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── Encriptación en reposo del state ────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── Bloquear acceso público al bucket de state ───────────────
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── DynamoDB Table para state locking ───────────────────────
# Evita que dos terraform apply corran simultáneamente
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "tf-state-lock"
  billing_mode = "PAY_PER_REQUEST" # Sin costo si no se usa
  hash_key     = "LockID"          # Nombre requerido por Terraform

  attribute {
    name = "LockID"
    type = "S" # String
  }

  tags = {
    Name      = "Terraform State Lock"
    Project   = "terraform-event-pipeline"
    ManagedBy = "terraform-bootstrap"
  }
}