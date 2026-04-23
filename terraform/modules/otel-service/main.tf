locals {
  has_target_groups = var.target_group_grpc_arn != null || var.target_group_http_arn != null
}

# ============================================================
# Task Definition
# ============================================================

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = var.task_execution_role
  task_role_arn            = var.task_role

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.container_image
      essential = true

      command = [
        "--config=env:OTEL_CONFIG",
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.aws_region
        },
        {
          name  = "OTEL_CONFIG"
          value = var.collector_config
        },
      ]

      # A configuração do collector é injetada via variável de ambiente em base64.
      # Na Fase 2, migrar para SSM Parameter Store ou Secrets Manager.
      secrets = []

      portMappings = [
        {
          name          = "otlp-grpc"
          containerPort = var.otlp_grpc_port
          hostPort      = var.otlp_grpc_port
          protocol      = "tcp"
        },
        {
          name          = "otlp-http"
          containerPort = var.otlp_http_port
          hostPort      = var.otlp_http_port
          protocol      = "tcp"
        },
        {
          name          = "health-check"
          containerPort = 13133
          hostPort      = 13133
          protocol      = "tcp"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:13133/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      # Configuração do collector montada via ConfigMap-like pattern.
      # O conteúdo do YAML é passado como variável de ambiente codificada.
      # Na Fase 2, substituir por volume montado via SSM ou S3.
      mountPoints  = []
      volumesFrom  = []
      stopTimeout  = 30
      startTimeout = 60
    }
  ])

  tags = {
    Name    = var.service_name
    Service = var.service_name
  }
}

# ============================================================
# ECS Service
# ============================================================

resource "aws_ecs_service" "this" {
  name                               = var.service_name
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  health_check_grace_period_seconds  = local.has_target_groups ? 60 : null
  enable_execute_command             = true
  propagate_tags                     = "SERVICE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.target_group_grpc_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_grpc_arn
      container_name   = var.service_name
      container_port   = var.otlp_grpc_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.target_group_http_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_http_arn
      container_name   = var.service_name
      container_port   = var.otlp_http_port
    }
  }

  dynamic "service_registries" {
    for_each = var.cloud_map_service_arn != null ? [1] : []
    content {
      registry_arn = var.cloud_map_service_arn
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name    = var.service_name
    Service = var.service_name
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ============================================================
# Application Autoscaling — implementado, desabilitado por variável
# ============================================================

resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
