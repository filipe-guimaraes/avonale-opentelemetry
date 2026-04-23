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

      command = var.container_command

      environment = [
        {
          name  = "BACKEND_CONFIG"
          value = var.backend_config
        },
      ]

      portMappings = [
        for port in var.container_ports : {
          name          = port.name
          containerPort = port.port
          hostPort      = port.port
          protocol      = "tcp"
        }
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
        command     = ["CMD-SHELL", "wget -qO- http://localhost:${var.health_check_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      mountPoints = []
      volumesFrom = []
      stopTimeout = 30
      startTimeout = 60
    }
  ])

  tags = {
    Name    = var.service_name
    Service = var.service_name
  }
}

resource "aws_ecs_service" "this" {
  name                  = var.service_name
  cluster               = var.cluster_id
  task_definition       = aws_ecs_task_definition.this.arn
  desired_count         = var.desired_count
  launch_type           = "FARGATE"
  platform_version      = "1.4.0"
  enable_execute_command = true
  propagate_tags        = "SERVICE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.cloud_map_service_arn
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
