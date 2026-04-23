# ============================================================
# Security Group — NLB Interno
# ============================================================

resource "aws_security_group" "nlb" {
  name        = "${var.name_prefix}-nlb-internal"
  description = "Security Group do NLB interno de ingestao OTLP. Aceita trafego apenas de origens internas autorizadas."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-nlb-internal"
  }
}

# IIS -> NLB: OTLP gRPC
resource "aws_vpc_security_group_ingress_rule" "nlb_from_iis_grpc" {
  security_group_id            = aws_security_group.nlb.id
  description                  = "OTLP gRPC do IIS para o NLB"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.existing_iis_security_group_id
}

# IIS -> NLB: OTLP HTTP
resource "aws_vpc_security_group_ingress_rule" "nlb_from_iis_http" {
  security_group_id            = aws_security_group.nlb.id
  description                  = "OTLP HTTP do IIS para o NLB"
  from_port                    = var.otlp_http_port
  to_port                      = var.otlp_http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.existing_iis_security_group_id
}

# Lambda ADOT -> NLB: OTLP gRPC (preparação futura)
resource "aws_vpc_security_group_ingress_rule" "nlb_from_lambda_grpc" {
  for_each = toset(var.lambda_adot_security_group_ids)

  security_group_id            = aws_security_group.nlb.id
  description                  = "OTLP gRPC de Lambda ADOT para o NLB"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# Lambda ADOT -> NLB: OTLP HTTP (preparação futura)
resource "aws_vpc_security_group_ingress_rule" "nlb_from_lambda_http" {
  for_each = toset(var.lambda_adot_security_group_ids)

  security_group_id            = aws_security_group.nlb.id
  description                  = "OTLP HTTP de Lambda ADOT para o NLB"
  from_port                    = var.otlp_http_port
  to_port                      = var.otlp_http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# API EC2 -> NLB: OTLP gRPC (opcional, controlado por variável)
resource "aws_vpc_security_group_ingress_rule" "nlb_from_api_ec2_grpc" {
  for_each = var.enable_api_otlp_ingestion ? toset(var.api_ec2_security_group_ids) : toset([])

  security_group_id            = aws_security_group.nlb.id
  description                  = "OTLP gRPC de API EC2 para o NLB"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# API EC2 -> NLB: OTLP HTTP (opcional, controlado por variável)
resource "aws_vpc_security_group_ingress_rule" "nlb_from_api_ec2_http" {
  for_each = var.enable_api_otlp_ingestion ? toset(var.api_ec2_security_group_ids) : toset([])

  security_group_id            = aws_security_group.nlb.id
  description                  = "OTLP HTTP de API EC2 para o NLB"
  from_port                    = var.otlp_http_port
  to_port                      = var.otlp_http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# NLB -> Frontend: egress
resource "aws_vpc_security_group_egress_rule" "nlb_to_frontend_grpc" {
  security_group_id            = aws_security_group.nlb.id
  description                  = "NLB para otel-frontend OTLP gRPC"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otel_frontend.id
}

resource "aws_vpc_security_group_egress_rule" "nlb_to_frontend_http" {
  security_group_id            = aws_security_group.nlb.id
  description                  = "NLB para otel-frontend OTLP HTTP"
  from_port                    = var.otlp_http_port
  to_port                      = var.otlp_http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otel_frontend.id
}

# ============================================================
# Security Group — otel-frontend
# ============================================================

resource "aws_security_group" "otel_frontend" {
  name        = "${var.name_prefix}-otel-frontend"
  description = "Security Group do ECS Service otel-frontend. Aceita OTLP apenas do NLB interno."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-otel-frontend"
  }
}

# NLB -> Frontend: OTLP gRPC
resource "aws_vpc_security_group_ingress_rule" "frontend_from_nlb_grpc" {
  security_group_id            = aws_security_group.otel_frontend.id
  description                  = "OTLP gRPC do NLB para o otel-frontend"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.nlb.id
}

# NLB -> Frontend: OTLP HTTP
resource "aws_vpc_security_group_ingress_rule" "frontend_from_nlb_http" {
  security_group_id            = aws_security_group.otel_frontend.id
  description                  = "OTLP HTTP do NLB para o otel-frontend"
  from_port                    = var.otlp_http_port
  to_port                      = var.otlp_http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.nlb.id
}

# Frontend -> Aggregator: egress OTLP gRPC
resource "aws_vpc_security_group_egress_rule" "frontend_to_aggregator_grpc" {
  security_group_id            = aws_security_group.otel_frontend.id
  description                  = "otel-frontend para otel-aggregator OTLP gRPC"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otel_aggregator.id
}

# Frontend: egress HTTPS para AWS APIs (ECR, CloudWatch, SSM)
resource "aws_vpc_security_group_egress_rule" "frontend_to_aws_apis" {
  security_group_id = aws_security_group.otel_frontend.id
  description       = "otel-frontend para AWS APIs via HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# ============================================================
# Security Group — otel-aggregator
# ============================================================

resource "aws_security_group" "otel_aggregator" {
  name        = "${var.name_prefix}-otel-aggregator"
  description = "Security Group do ECS Service otel-aggregator. Aceita OTLP do frontend e fontes autorizadas."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-otel-aggregator"
  }
}

# Frontend -> Aggregator: OTLP gRPC
resource "aws_vpc_security_group_ingress_rule" "aggregator_from_frontend_grpc" {
  security_group_id            = aws_security_group.otel_aggregator.id
  description                  = "OTLP gRPC do otel-frontend para o otel-aggregator"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otel_frontend.id
}

# Lambda ADOT -> Aggregator: OTLP gRPC (preparação futura)
resource "aws_vpc_security_group_ingress_rule" "aggregator_from_lambda_grpc" {
  for_each = toset(var.lambda_adot_security_group_ids)

  security_group_id            = aws_security_group.otel_aggregator.id
  description                  = "OTLP gRPC de Lambda ADOT para o otel-aggregator"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# Lambda ADOT -> Aggregator: OTLP HTTP (preparação futura)
resource "aws_vpc_security_group_ingress_rule" "aggregator_from_lambda_http" {
  for_each = toset(var.lambda_adot_security_group_ids)

  security_group_id            = aws_security_group.otel_aggregator.id
  description                  = "OTLP HTTP de Lambda ADOT para o otel-aggregator"
  from_port                    = var.otlp_http_port
  to_port                      = var.otlp_http_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# API EC2 -> Aggregator: OTLP gRPC (opcional)
resource "aws_vpc_security_group_ingress_rule" "aggregator_from_api_ec2_grpc" {
  for_each = var.enable_api_otlp_ingestion ? toset(var.api_ec2_security_group_ids) : toset([])

  security_group_id            = aws_security_group.otel_aggregator.id
  description                  = "OTLP gRPC de API EC2 para o otel-aggregator"
  from_port                    = var.otlp_grpc_port
  to_port                      = var.otlp_grpc_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

# Aggregator: egress HTTPS para AWS APIs
resource "aws_vpc_security_group_egress_rule" "aggregator_to_aws_apis" {
  security_group_id = aws_security_group.otel_aggregator.id
  description       = "otel-aggregator para AWS APIs via HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# ============================================================
# Security Group — Mimir
# ============================================================

resource "aws_security_group" "mimir" {
  name        = "${var.name_prefix}-mimir"
  description = "Security Group do Mimir. Aceita trafego apenas do otel-aggregator."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-mimir"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mimir_from_aggregator" {
  security_group_id            = aws_security_group.mimir.id
  description                  = "Metricas do otel-aggregator para o Mimir"
  from_port                    = 9009
  to_port                      = 9009
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otel_aggregator.id
}

resource "aws_vpc_security_group_egress_rule" "mimir_to_aws_apis" {
  security_group_id = aws_security_group.mimir.id
  description       = "Mimir para AWS APIs via HTTPS (S3)"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# ============================================================
# Security Group — Tempo
# ============================================================

resource "aws_security_group" "tempo" {
  name        = "${var.name_prefix}-tempo"
  description = "Security Group do Tempo. Aceita trafego apenas do otel-aggregator."
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-tempo"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tempo_from_aggregator_grpc" {
  security_group_id            = aws_security_group.tempo.id
  description                  = "Traces OTLP gRPC do otel-aggregator para o Tempo"
  from_port                    = 4317
  to_port                      = 4317
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otel_aggregator.id
}

resource "aws_vpc_security_group_egress_rule" "tempo_to_aws_apis" {
  security_group_id = aws_security_group.tempo.id
  description       = "Tempo para AWS APIs via HTTPS (S3)"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Egress do aggregator para Mimir
resource "aws_vpc_security_group_egress_rule" "aggregator_to_mimir" {
  security_group_id            = aws_security_group.otel_aggregator.id
  description                  = "otel-aggregator para Mimir"
  from_port                    = 9009
  to_port                      = 9009
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.mimir.id
}

# Egress do aggregator para Tempo
resource "aws_vpc_security_group_egress_rule" "aggregator_to_tempo" {
  security_group_id            = aws_security_group.otel_aggregator.id
  description                  = "otel-aggregator para Tempo OTLP gRPC"
  from_port                    = 4317
  to_port                      = 4317
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tempo.id
}
