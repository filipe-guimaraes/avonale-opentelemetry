resource "aws_lb" "this" {
  name               = "${var.name_prefix}-nlb-internal"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
  security_groups    = [var.nlb_sg_id]

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.name_prefix}-nlb-internal"
  }
}

# ============================================================
# Target Groups
# ============================================================

resource "aws_lb_target_group" "otlp_grpc" {
  name        = "${var.name_prefix}-otlp-grpc"
  port        = var.otlp_grpc_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name     = "${var.name_prefix}-otlp-grpc"
    Protocol = "grpc"
    Port     = tostring(var.otlp_grpc_port)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "otlp_http" {
  name        = "${var.name_prefix}-otlp-http"
  port        = var.otlp_http_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name     = "${var.name_prefix}-otlp-http"
    Protocol = "http"
    Port     = tostring(var.otlp_http_port)
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================
# Listeners
# ============================================================

resource "aws_lb_listener" "otlp_grpc" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.otlp_grpc_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.otlp_grpc.arn
  }

  tags = {
    Name = "${var.name_prefix}-listener-otlp-grpc"
  }
}

resource "aws_lb_listener" "otlp_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.otlp_http_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.otlp_http.arn
  }

  tags = {
    Name = "${var.name_prefix}-listener-otlp-http"
  }
}
