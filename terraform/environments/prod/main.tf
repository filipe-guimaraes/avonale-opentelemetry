terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  otel_frontend_name   = "${local.name_prefix}-otel-frontend"
  otel_aggregator_name = "${local.name_prefix}-otel-aggregator"
  mimir_name           = "${local.name_prefix}-mimir"
  tempo_name           = "${local.name_prefix}-tempo"

  otlp_grpc_port = 4317
  otlp_http_port = 4318

  otel_collector_image = "otel/opentelemetry-collector-contrib:0.139.0"
  mimir_image          = "${aws_ecr_repository.mimir.repository_url}:latest"
  tempo_image          = "${aws_ecr_repository.tempo.repository_url}:latest"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  otel_frontend_config = templatefile("${path.module}/../../templates/otel-frontend.yaml.tftpl", {
    otlp_grpc_port      = local.otlp_grpc_port
    otlp_http_port      = local.otlp_http_port
    aggregator_endpoint = "${module.cloud_map.aggregator_dns_name}:${local.otlp_grpc_port}"
    environment         = var.environment
    service_name        = local.otel_frontend_name
  })

  otel_aggregator_config = templatefile("${path.module}/../../templates/otel-aggregator.yaml.tftpl", {
    otlp_grpc_port = local.otlp_grpc_port
    otlp_http_port = local.otlp_http_port
    environment    = var.environment
    service_name   = local.otel_aggregator_name
    mimir_endpoint = "${module.cloud_map.mimir_dns_name}:9009"
    tempo_endpoint = "${module.cloud_map.tempo_dns_name}:4317"
  })

  mimir_config = templatefile("${path.module}/../../templates/mimir.yaml.tftpl", {
    mimir_bucket_name = var.mimir_bucket_name
    aws_region        = var.aws_region
  })

  tempo_config = templatefile("${path.module}/../../templates/tempo.yaml.tftpl", {
    tempo_bucket_name = var.tempo_bucket_name
    aws_region        = var.aws_region
  })
}

# ============================================================
# ECR Repository for Custom Tempo Image
# ============================================================

resource "aws_ecr_repository" "tempo" {
  name                 = "${local.name_prefix}-tempo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

# ============================================================
# ECR Repository for Custom Mimir Image
# ============================================================

resource "aws_ecr_repository" "mimir" {
  name                 = "${local.name_prefix}-mimir"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

# ============================================================
# Cloud Map — Service Discovery
# ============================================================

module "cloud_map" {
  source = "../../modules/cloud-map"

  namespace_name          = "observability.local"
  vpc_id                  = var.vpc_id
  aggregator_service_name = "otel-aggregator"
}

# ============================================================
# VPC Context — leitura de atributos da VPC existente
# ============================================================

module "vpc_context" {
  source = "../../modules/vpc-context"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
}

# ============================================================
# IAM
# ============================================================

module "iam" {
  source = "../../modules/iam"

  name_prefix          = local.name_prefix
  otel_frontend_name   = local.otel_frontend_name
  otel_aggregator_name = local.otel_aggregator_name
  mimir_name           = local.mimir_name
  tempo_name           = local.tempo_name
  mimir_bucket_name    = var.mimir_bucket_name
  tempo_bucket_name    = var.tempo_bucket_name
  aws_region           = var.aws_region
  account_id           = module.vpc_context.account_id
}

# ============================================================
# CloudWatch Logs
# ============================================================

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  otel_frontend_name   = local.otel_frontend_name
  otel_aggregator_name = local.otel_aggregator_name
  mimir_name           = local.mimir_name
  tempo_name           = local.tempo_name
  log_retention_days   = var.log_retention_days
}

# ============================================================
# Security Groups
# ============================================================

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix                    = local.name_prefix
  vpc_id                         = var.vpc_id
  otlp_grpc_port                 = local.otlp_grpc_port
  otlp_http_port                 = local.otlp_http_port
  existing_iis_security_group_id = var.existing_iis_security_group_id
  lambda_adot_security_group_ids = var.lambda_adot_security_group_ids
  api_ec2_security_group_ids     = var.api_ec2_security_group_ids
  enable_api_otlp_ingestion      = var.enable_api_otlp_ingestion
}

# ============================================================
# NLB Interno
# ============================================================

module "nlb_internal" {
  source = "../../modules/nlb-internal"

  name_prefix        = local.name_prefix
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  nlb_sg_id          = module.security_groups.nlb_sg_id
  otlp_grpc_port     = local.otlp_grpc_port
  otlp_http_port     = local.otlp_http_port
}

# ============================================================
# ECS Cluster
# ============================================================

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name_prefix = local.name_prefix
}

# ============================================================
# ECS Service — otel-frontend
# ============================================================

module "otel_frontend" {
  source = "../../modules/otel-service"

  service_name        = local.otel_frontend_name
  name_prefix         = local.name_prefix
  cluster_id          = module.ecs_cluster.cluster_id
  cluster_name        = module.ecs_cluster.cluster_name
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  security_group_id   = module.security_groups.frontend_sg_id
  task_execution_role = module.iam.ecs_task_execution_role_arn
  task_role           = module.iam.otel_frontend_task_role_arn
  cpu                 = var.cpu_frontend
  memory              = var.memory_frontend
  desired_count       = var.desired_count_frontend
  otlp_grpc_port      = local.otlp_grpc_port
  otlp_http_port      = local.otlp_http_port
  log_group_name      = module.cloudwatch.frontend_log_group_name
  aws_region          = var.aws_region
  container_image     = local.otel_collector_image
  collector_config    = local.otel_frontend_config

  cloud_map_service_arn = null

  # NLB target groups
  target_group_grpc_arn = module.nlb_internal.target_group_grpc_arn
  target_group_http_arn = module.nlb_internal.target_group_http_arn

  # Autoscaling
  enable_autoscaling = var.enable_autoscaling_frontend
  min_capacity       = var.min_capacity_frontend
  max_capacity       = var.max_capacity_frontend

  depends_on = [module.nlb_internal]
}

# ============================================================
# ECS Service — otel-aggregator
# ============================================================

module "otel_aggregator" {
  source = "../../modules/otel-service"

  service_name        = local.otel_aggregator_name
  name_prefix         = local.name_prefix
  cluster_id          = module.ecs_cluster.cluster_id
  cluster_name        = module.ecs_cluster.cluster_name
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  security_group_id   = module.security_groups.aggregator_sg_id
  task_execution_role = module.iam.ecs_task_execution_role_arn
  task_role           = module.iam.otel_aggregator_task_role_arn
  cpu                 = var.cpu_aggregator
  memory              = var.memory_aggregator
  desired_count       = var.desired_count_aggregator
  otlp_grpc_port      = local.otlp_grpc_port
  otlp_http_port      = local.otlp_http_port
  log_group_name      = module.cloudwatch.aggregator_log_group_name
  aws_region          = var.aws_region
  container_image     = local.otel_collector_image
  collector_config    = local.otel_aggregator_config

  cloud_map_service_arn = module.cloud_map.aggregator_service_arn

  # O aggregator nao e exposto diretamente pelo NLB externo nesta fase
  target_group_grpc_arn = null
  target_group_http_arn = null

  # Autoscaling
  enable_autoscaling = var.enable_autoscaling_aggregator
  min_capacity       = var.min_capacity_aggregator
  max_capacity       = var.max_capacity_aggregator
}

# ============================================================
# S3 — Storage futuro para Mimir e Tempo
# ============================================================

module "s3_observability" {
  source = "../../modules/s3-observability"

  name_prefix       = local.name_prefix
  mimir_bucket_name = var.mimir_bucket_name
  tempo_bucket_name = var.tempo_bucket_name
}

# ============================================================
# Mimir
# ============================================================

module "mimir" {
  source = "../../modules/observability-backend"

  service_name          = local.mimir_name
  cluster_id            = module.ecs_cluster.cluster_id
  vpc_id                = var.vpc_id
  private_subnet_ids    = var.private_subnet_ids
  security_group_id     = module.security_groups.mimir_sg_id
  task_execution_role   = module.iam.ecs_task_execution_role_arn
  task_role             = module.iam.mimir_task_role_arn
  cpu                   = 1024
  memory                = 2048
  desired_count         = 1
  container_image       = local.mimir_image
  container_command = []
  backend_config = ""
  #container_command     = ["/bin/sh", "-c", "printf '%s' \"$BACKEND_CONFIG\" > /tmp/config.yaml && /bin/mimir -config.file=/tmp/config.yaml -target=all -server.http-listen-address=0.0.0.0 -server.grpc-listen-address=0.0.0.0"]
  #backend_config        = local.mimir_config
  log_group_name        = module.cloudwatch.mimir_log_group_name
  aws_region            = var.aws_region
  cloud_map_service_arn = module.cloud_map.mimir_service_arn

  container_ports = [
    { name = "http", port = 8080 },
    { name = "grpc", port = 9095 },
    { name = "memberlist", port = 7946 },
  ]

  health_check_port = 8080
  health_check_path = "/ready"

  depends_on = [module.cloud_map]
}

# ============================================================
# Tempo
# ============================================================

module "tempo" {
  source = "../../modules/observability-backend"

  service_name          = local.tempo_name
  cluster_id            = module.ecs_cluster.cluster_id
  vpc_id                = var.vpc_id
  private_subnet_ids    = var.private_subnet_ids
  security_group_id     = module.security_groups.tempo_sg_id
  task_execution_role   = module.iam.ecs_task_execution_role_arn
  task_role             = module.iam.tempo_task_role_arn
  cpu                   = 512
  memory                = 2048
  desired_count         = 1
  container_image       = local.tempo_image
  log_group_name        = module.cloudwatch.tempo_log_group_name
  aws_region            = var.aws_region
  cloud_map_service_arn = module.cloud_map.tempo_service_arn
  backend_config        = ""
  container_command     = []
  container_ports = [
    { name = "http", port = 3200 },
    { name = "otlp-grpc", port = 4317 },
    { name = "otlp-http", port = 4318 },
    { name = "grpc", port = 9095 },
  ]

  health_check_port = 3200
  health_check_path = "/ready"

  depends_on = [module.cloud_map]
}