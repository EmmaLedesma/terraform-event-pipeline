# terraform-event-pipeline

**Infraestructura event-driven en AWS provisionada con Terraform**

GitHub: https://github.com/EmmaLedesma/terraform-event-pipeline

[![Terraform Apply](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-apply.yml/badge.svg)](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-apply.yml)
[![Terraform Plan](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-plan.yml/badge.svg)](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-plan.yml)
[![Terraform](https://img.shields.io/badge/terraform-1.7+-purple)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-us--east--1-orange)](https://aws.amazon.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📌 Problema que Resuelve

Los equipos de infraestructura modernos necesitan aprovisionar recursos en la nube de forma **reproducible, versionada y automatizada**. Este proyecto implementa un **pipeline event-driven completo en AWS** definido 100% como código con Terraform — sin ClickOps, sin configuración manual.

Cuando se sube un archivo a S3, una función Lambda lo procesa automáticamente y distribuye el evento a una cola SQS y un topic SNS. Toda la infraestructura puede destruirse y recrearse desde cero con un solo comando.

Demuestra el stack IaC que usan los equipos de Cloud Engineering y DevOps profesionales:

- Infraestructura reproducible con módulos Terraform reutilizables
- Estado remoto con S3 backend y bloqueo con DynamoDB
- Separación de environments (dev/prod) con variables y locals
- Pipeline CI/CD: plan automático en PRs, apply automático en merge

---

## 🏗️ Arquitectura

```
Developer
    │
    ├── 💻 Local
    │       └── terraform apply
    │               ├── S3 Bucket (input)       → recibe archivos
    │               ├── Lambda Processor        → procesa eventos
    │               ├── SQS Queue               → mensajes async
    │               └── SNS Topic               → notificaciones
    │
    └── 🔀 GitHub
            ├── Pull Request → Terraform Plan
            │       ├── terraform fmt -check
            │       ├── terraform validate
            │       └── terraform plan (comentado en el PR)
            │
            └── Push a master → Terraform Apply
                    └── terraform apply -auto-approve
                                └── AWS us-east-1
```

### Flujo del Pipeline

```
[Archivo subido a S3]
        │
        ▼
[S3 Event Notification]
        │
        ▼
[Lambda Processor — Node.js 20.x]
        │
        ├──▶ [SQS Queue] → procesamiento async
        │
        └──▶ [SNS Topic] → notificaciones / alertas
```

### Componentes Principales

#### 🗂️ Bootstrap — Backend Remoto
- Bucket S3 dedicado para guardar el Terraform state con versionado y encriptación AES256
- Tabla DynamoDB para state locking — evita conflictos en applies simultáneos
- Se ejecuta una sola vez, antes de cualquier otro módulo

#### 📦 Módulos Locales Reutilizables
- **`modules/storage`** — S3 bucket con trigger hacia Lambda, block public access, versioning configurable
- **`modules/messaging`** — SQS queue + SNS topic con políticas IAM, suscripción email opcional
- **`modules/compute`** — Lambda function + IAM role con least privilege, empaquetado automático del código

#### 🌍 Environment Dev
- Ensambla los tres módulos con variables y locals centralizados
- Naming convention consistente: `{proyecto}-{ambiente}-{recurso}`
- Tags comunes aplicados a todos los recursos via `merge()`

#### 🔄 GitHub Actions CI/CD
- **Plan** en cada Pull Request — resultado comentado automáticamente en el PR
- **Apply** en cada push a master — deploy automático sin intervención manual
- Credenciales AWS via GitHub Secrets — sin access keys en el código

---

## 🚀 Recursos AWS Provisionados

| Recurso | Nombre | Módulo |
|---------|--------|--------|
| S3 Bucket (input) | `event-pipeline-dev-input-{account}` | storage |
| S3 Bucket Notification | trigger `s3:ObjectCreated:*` | storage |
| Lambda Function | `event-pipeline-dev-processor` | compute |
| IAM Role | `event-pipeline-dev-lambda-role` | compute |
| IAM Role Policy | `event-pipeline-dev-lambda-policy` | compute |
| Lambda Permission | `AllowS3Invoke` | compute |
| SQS Queue | `event-pipeline-dev-queue` | messaging |
| SQS Queue Policy | allow Lambda SendMessage | messaging |
| SNS Topic | `event-pipeline-dev-notifications` | messaging |
| S3 Backend | `tf-state-emmanuel-ledesma-2026` | bootstrap |
| DynamoDB Table | `tf-state-lock` | bootstrap |

**Total: 11 recursos provisionados en AWS**

---

## ✅ Features de Terraform Demostradas

- **Remote backend** — State en S3 con DynamoDB locking
- **Módulos locales** — `storage`, `messaging`, `compute` reutilizables
- **Variables & outputs** — Environments parametrizados y desacoplados
- **Locals** — Naming convention y tags centralizados con `merge()`
- **Data sources** — `archive_file` para empaquetar Lambda automáticamente
- **`depends_on`** — Dependencias explícitas entre recursos de distintos módulos
- **`lifecycle`** — `prevent_destroy` en recursos críticos
- **`jsonencode()`** — Políticas IAM como HCL, sin JSON inline
- **CI/CD** — GitHub Actions: plan en PR, apply en merge a master

---

## 📁 Estructura del Proyecto

```
terraform-event-pipeline/
├── bootstrap/                    # Backend: S3 + DynamoDB (una sola vez)
│   ├── main.tf
│   └── outputs.tf
│
├── modules/                      # Módulos locales reutilizables
│   ├── storage/                  # S3 bucket + trigger
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── messaging/                # SQS + SNS
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/                  # Lambda + IAM
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   └── dev/                      # Environment dev
│       ├── main.tf               # Ensambla los 3 módulos + backend config
│       ├── locals.tf             # Naming convention y common tags
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars      # Valores concretos (en .gitignore)
│
├── lambda/
│   └── processor/
│       └── index.js              # Handler Node.js 20.x
│
└── .github/
    └── workflows/
        ├── terraform-plan.yml    # PR: fmt + validate + plan
        └── terraform-apply.yml   # master: apply automático
```

---

## ⚡ Quick Start

### Requisitos
- Terraform >= 1.7.0
- AWS CLI configurado
- Cuenta AWS con usuario IAM

### 1. Configurar credenciales

```bash
aws configure --profile terraform-pipeline
```

### 2. Bootstrap del backend (solo una vez)

```bash
cd bootstrap
terraform init
terraform apply
```

### 3. Desplegar el pipeline

```bash
cd ../environments/dev
terraform init
terraform apply
```

### 4. Probar el pipeline

```bash
# Crear archivo de prueba
echo '{"test": "event-pipeline", "author": "emmanuel-ledesma"}' > test.json

# Subir al bucket — dispara la Lambda automáticamente
aws s3 cp test.json s3://event-pipeline-dev-input-<account-id>/ \
  --profile terraform-pipeline

# Ver logs en tiempo real
aws logs tail /aws/lambda/event-pipeline-dev-processor --follow \
  --profile terraform-pipeline
```

Output esperado en los logs:
```
INFO  Processing: s3://event-pipeline-dev-input-.../test.json (138 bytes)
INFO  SQS message sent for: test.json
INFO  SNS notification sent for: test.json
```

### 5. Destruir todo

```bash
terraform destroy
```

---

## 🔄 CI/CD Workflow

| Evento | Acción |
|--------|--------|
| Pull Request → master | `terraform fmt` + `validate` + `plan` comentado en el PR |
| Push → master | `terraform apply -auto-approve` |
| Manual (workflow_dispatch) | `terraform apply` on demand |

### Configurar GitHub Secrets

```bash
gh secret set AWS_ACCESS_KEY_ID     --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "..."
gh secret set AWS_ACCOUNT_ID        --body "123456789012"
```

---

## 🔐 Seguridad Destacada

- **Least privilege IAM** — Lambda solo puede acceder a su propio bucket, queue y topic
- **State encriptado** — AES256 en el bucket de backend
- **Block public access** — todos los buckets S3 bloqueados públicamente
- **DynamoDB locking** — previene corrupción de state en applies concurrentes
- **Sin credenciales en código** — AWS profile en local, GitHub Secrets en CI
- **`prevent_destroy`** — lifecycle guard en recursos críticos del bootstrap

---

## 💼 Este Proyecto Demuestra

### 🔹 Terraform IaC Profesional
- Módulos locales con interfaz clara (variables/outputs) — reutilizables entre environments
- Remote backend con locking — estándar en equipos reales
- Separación bootstrap / módulos / environments — arquitectura escalable a múltiples ambientes

### 🔹 AWS Event-Driven
- Patrón S3 → Lambda → SQS/SNS — cloud-native, serverless, sin servidores que gestionar
- IAM con mínimo privilegio — cada recurso solo tiene los permisos que necesita
- Empaquetado automático de Lambda con `archive_file` data source

### 🔹 CI/CD con GitHub Actions
- Plan automático en PRs — revisión de cambios antes de aplicar
- Apply automático en merge — infraestructura siempre sincronizada con el código
- Path filters — los workflows solo corren cuando cambia infraestructura real

### 🔹 Buenas Prácticas IaC
- Naming convention consistente via locals
- Tags en todos los recursos para trazabilidad y billing
- `.gitignore` que excluye state files, `.terraform/` y `.tfvars`
- Conventional commits en todo el historial

---

## 🔮 Mejoras Futuras

- 🌍 Agregar environment `prod` con variables distintas
- 🔒 OIDC keyless authentication para GitHub Actions (reemplazar access keys)
- 📊 CloudWatch Dashboard para métricas del pipeline
- 🧪 Checkov para security scanning del código Terraform en CI
- 🗂️ Módulos del Terraform Registry (VPC, ECS) combinados con módulos locales
- 🔔 Notificaciones de deploy a Slack via SNS
- 📦 Terraform workspaces para gestión de múltiples environments

---

## 📝 Licencia

Proyecto orientado al aprendizaje y desarrollo de portfolio profesional.
Uso libre.

_Code made by Emma Ledesma_  
🔗 https://www.linkedin.com/in/emmanuel-ledesmam/

---

# ===========================
# English Version
# ===========================

# terraform-event-pipeline

**Event-driven AWS infrastructure provisioned with Terraform**

GitHub: https://github.com/EmmaLedesma/terraform-event-pipeline

[![Terraform Apply](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-apply.yml/badge.svg)](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-apply.yml)
[![Terraform Plan](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-plan.yml/badge.svg)](https://github.com/EmmaLedesma/terraform-event-pipeline/actions/workflows/terraform-plan.yml)
[![Terraform](https://img.shields.io/badge/terraform-1.7+-purple)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-us--east--1-orange)](https://aws.amazon.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📌 Problem Statement

Modern infrastructure teams need to provision cloud resources in a **reproducible, versioned and automated** way. This project implements a **complete event-driven pipeline on AWS** defined 100% as code with Terraform — no ClickOps, no manual configuration.

When a file is uploaded to S3, a Lambda function automatically processes it and distributes the event to an SQS queue and SNS topic. The entire infrastructure can be destroyed and recreated from scratch with a single command.

It demonstrates the IaC stack used by professional Cloud Engineering and DevOps teams:

- Reproducible infrastructure with reusable Terraform modules
- Remote state with S3 backend and DynamoDB locking
- Environment separation (dev/prod) with variables and locals
- CI/CD pipeline: automatic plan on PRs, automatic apply on merge

---

## 🏗️ Architecture

```
Developer
    │
    ├── 💻 Local
    │       └── terraform apply
    │               ├── S3 Bucket (input)       → receives files
    │               ├── Lambda Processor        → processes events
    │               ├── SQS Queue               → async messages
    │               └── SNS Topic               → notifications
    │
    └── 🔀 GitHub
            ├── Pull Request → Terraform Plan
            │       ├── terraform fmt -check
            │       ├── terraform validate
            │       └── terraform plan (commented on PR)
            │
            └── Push to master → Terraform Apply
                    └── terraform apply -auto-approve
                                └── AWS us-east-1
```

### Pipeline Flow

```
[File uploaded to S3]
        │
        ▼
[S3 Event Notification]
        │
        ▼
[Lambda Processor — Node.js 20.x]
        │
        ├──▶ [SQS Queue] → async processing
        │
        └──▶ [SNS Topic] → notifications / alerts
```

### Core Components

#### 🗂️ Bootstrap — Remote Backend
- Dedicated S3 bucket for Terraform state with versioning and AES256 encryption
- DynamoDB table for state locking — prevents conflicts on concurrent applies
- Runs once, before any other module

#### 📦 Reusable Local Modules
- **`modules/storage`** — S3 bucket with Lambda trigger, public access block, configurable versioning
- **`modules/messaging`** — SQS queue + SNS topic with IAM policies, optional email subscription
- **`modules/compute`** — Lambda function + least privilege IAM role, automatic code packaging

#### 🌍 Dev Environment
- Assembles the three modules with centralized variables and locals
- Consistent naming convention: `{project}-{environment}-{resource}`
- Common tags applied to all resources via `merge()`

#### 🔄 GitHub Actions CI/CD
- **Plan** on every Pull Request — result automatically commented on the PR
- **Apply** on every push to master — automatic deploy without manual intervention
- AWS credentials via GitHub Secrets — no access keys in code

---

## 🚀 Provisioned AWS Resources

| Resource | Name | Module |
|----------|------|--------|
| S3 Bucket (input) | `event-pipeline-dev-input-{account}` | storage |
| S3 Bucket Notification | trigger `s3:ObjectCreated:*` | storage |
| Lambda Function | `event-pipeline-dev-processor` | compute |
| IAM Role | `event-pipeline-dev-lambda-role` | compute |
| IAM Role Policy | `event-pipeline-dev-lambda-policy` | compute |
| Lambda Permission | `AllowS3Invoke` | compute |
| SQS Queue | `event-pipeline-dev-queue` | messaging |
| SQS Queue Policy | allow Lambda SendMessage | messaging |
| SNS Topic | `event-pipeline-dev-notifications` | messaging |
| S3 Backend | `tf-state-emmanuel-ledesma-2026` | bootstrap |
| DynamoDB Table | `tf-state-lock` | bootstrap |

**Total: 11 resources provisioned on AWS**

---

## ✅ Terraform Features Demonstrated

- **Remote backend** — State in S3 with DynamoDB locking
- **Local modules** — reusable `storage`, `messaging`, `compute`
- **Variables & outputs** — Parameterized, decoupled environments
- **Locals** — Centralized naming convention and tags via `merge()`
- **Data sources** — `archive_file` to automatically package Lambda
- **`depends_on`** — Explicit dependencies across module boundaries
- **`lifecycle`** — `prevent_destroy` on critical resources
- **`jsonencode()`** — IAM policies as HCL, no inline JSON strings
- **CI/CD** — GitHub Actions: plan on PR, apply on merge to master

---

## 📁 Project Structure

```
terraform-event-pipeline/
├── bootstrap/                    # Backend: S3 + DynamoDB (one-time)
│   ├── main.tf
│   └── outputs.tf
│
├── modules/                      # Reusable local modules
│   ├── storage/                  # S3 bucket + trigger
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── messaging/                # SQS + SNS
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/                  # Lambda + IAM
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   └── dev/                      # Dev environment
│       ├── main.tf               # Assembles 3 modules + backend config
│       ├── locals.tf             # Naming convention and common tags
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars      # Concrete values (.gitignore'd)
│
├── lambda/
│   └── processor/
│       └── index.js              # Node.js 20.x handler
│
└── .github/
    └── workflows/
        ├── terraform-plan.yml    # PR: fmt + validate + plan
        └── terraform-apply.yml   # master: auto apply
```

---

## ⚡ Quick Start

### Prerequisites
- Terraform >= 1.7.0
- AWS CLI configured
- AWS account with IAM user

### 1. Configure credentials

```bash
aws configure --profile terraform-pipeline
```

### 2. Bootstrap the backend (only once)

```bash
cd bootstrap
terraform init
terraform apply
```

### 3. Deploy the pipeline

```bash
cd ../environments/dev
terraform init
terraform apply
```

### 4. Test the pipeline

```bash
# Create test file
echo '{"test": "event-pipeline", "author": "emmanuel-ledesma"}' > test.json

# Upload to bucket — automatically triggers Lambda
aws s3 cp test.json s3://event-pipeline-dev-input-<account-id>/ \
  --profile terraform-pipeline

# Watch logs in real time
aws logs tail /aws/lambda/event-pipeline-dev-processor --follow \
  --profile terraform-pipeline
```

Expected log output:
```
INFO  Processing: s3://event-pipeline-dev-input-.../test.json (138 bytes)
INFO  SQS message sent for: test.json
INFO  SNS notification sent for: test.json
```

### 5. Destroy everything

```bash
terraform destroy
```

---

## 🔄 CI/CD Workflow

| Event | Action |
|-------|--------|
| Pull Request → master | `terraform fmt` + `validate` + `plan` commented on PR |
| Push → master | `terraform apply -auto-approve` |
| Manual (workflow_dispatch) | `terraform apply` on demand |

### Configure GitHub Secrets

```bash
gh secret set AWS_ACCESS_KEY_ID     --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "..."
gh secret set AWS_ACCOUNT_ID        --body "123456789012"
```

---

## 🔐 Security Highlights

- **Least privilege IAM** — Lambda can only access its own bucket, queue and topic
- **Encrypted state** — AES256 on the backend bucket
- **Block public access** — all S3 buckets fully blocked from public
- **DynamoDB locking** — prevents state corruption on concurrent applies
- **No credentials in code** — AWS profile locally, GitHub Secrets in CI
- **`prevent_destroy`** — lifecycle guard on critical bootstrap resources

---

## 💼 This Project Clearly Demonstrates

### 🔹 Professional Terraform IaC
- Local modules with clean interface (variables/outputs) — reusable across environments
- Remote backend with locking — standard in real engineering teams
- Bootstrap / modules / environments separation — architecture that scales to multiple environments

### 🔹 AWS Event-Driven
- S3 → Lambda → SQS/SNS pattern — cloud-native, serverless, no servers to manage
- Least privilege IAM — each resource only has the permissions it needs
- Automatic Lambda packaging with `archive_file` data source

### 🔹 CI/CD with GitHub Actions
- Automatic plan on PRs — review changes before applying
- Automatic apply on merge — infrastructure always in sync with code
- Path filters — workflows only run when actual infrastructure changes

### 🔹 IaC Best Practices
- Consistent naming convention via locals
- Tags on all resources for traceability and billing
- `.gitignore` excludes state files, `.terraform/` and `.tfvars`
- Conventional commits throughout the entire history

---

## 🔮 Future Improvements

- 🌍 Add `prod` environment with different variables
- 🔒 OIDC keyless authentication for GitHub Actions (replace access keys)
- 📊 CloudWatch Dashboard for pipeline metrics
- 🧪 Checkov for Terraform security scanning in CI
- 🗂️ Terraform Registry modules (VPC, ECS) combined with local modules
- 🔔 Deploy notifications to Slack via SNS
- 📦 Terraform workspaces for multi-environment management

---

## 📝 License

Educational project designed for learning and professional portfolio building.
Free to use and modify.

_Code made by Emma Ledesma_  
🔗 https://www.linkedin.com/in/emmanuel-ledesmam/