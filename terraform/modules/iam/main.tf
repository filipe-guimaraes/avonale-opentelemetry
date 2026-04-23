data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ============================================================
# ECS Task Execution Role (compartilhada entre frontend e aggregator)
# ============================================================

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.name_prefix}-ecs-task-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Permissão adicional para leitura de SSM Parameter Store (preparação para fases futuras)
data "aws_iam_policy_document" "ecs_task_execution_extras" {
  statement {
    sid    = "SSMReadOnly"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/${var.name_prefix}/*",
    ]
  }

  statement {
    sid    = "SecretsManagerReadOnly"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:${var.name_prefix}/*",
    ]
  }

  statement {
    sid    = "KMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${var.account_id}:key/*",
    ]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values = [
        "ssm.${var.aws_region}.amazonaws.com",
        "secretsmanager.${var.aws_region}.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_task_execution_extras" {
  name        = "${var.name_prefix}-ecs-task-execution-extras"
  description = "Permissões adicionais para ECS Task Execution Role (SSM, Secrets, KMS)."
  policy      = data.aws_iam_policy_document.ecs_task_execution_extras.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_extras" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_extras.arn
}

# ============================================================
# Task Role — otel-frontend
# ============================================================

resource "aws_iam_role" "otel_frontend_task" {
  name               = "${var.otel_frontend_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.otel_frontend_name}-task"
  }
}

data "aws_iam_policy_document" "otel_frontend_task" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/ecs/${var.otel_frontend_name}:*",
    ]
  }

  statement {
    sid    = "SSMExecuteCommand"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMConfigRead"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/${var.otel_frontend_name}/*",
    ]
  }
}

resource "aws_iam_policy" "otel_frontend_task" {
  name        = "${var.otel_frontend_name}-task-policy"
  description = "Política mínima para a task role do otel-frontend."
  policy      = data.aws_iam_policy_document.otel_frontend_task.json
}

resource "aws_iam_role_policy_attachment" "otel_frontend_task" {
  role       = aws_iam_role.otel_frontend_task.name
  policy_arn = aws_iam_policy.otel_frontend_task.arn
}

# ============================================================
# Task Role — otel-aggregator
# ============================================================

resource "aws_iam_role" "otel_aggregator_task" {
  name               = "${var.otel_aggregator_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.otel_aggregator_name}-task"
  }
}

data "aws_iam_policy_document" "otel_aggregator_task" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/ecs/${var.otel_aggregator_name}:*",
    ]
  }

  statement {
    sid    = "SSMExecuteCommand"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3ObservabilityWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::*-mimir-*",
      "arn:aws:s3:::*-mimir-*/*",
      "arn:aws:s3:::*-tempo-*",
      "arn:aws:s3:::*-tempo-*/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [var.account_id]
    }
  }

  statement {
    sid    = "SSMConfigRead"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/${var.otel_aggregator_name}/*",
    ]
  }
}

resource "aws_iam_policy" "otel_aggregator_task" {
  name        = "${var.otel_aggregator_name}-task-policy"
  description = "Política mínima para a task role do otel-aggregator."
  policy      = data.aws_iam_policy_document.otel_aggregator_task.json
}

resource "aws_iam_role_policy_attachment" "otel_aggregator_task" {
  role       = aws_iam_role.otel_aggregator_task.name
  policy_arn = aws_iam_policy.otel_aggregator_task.arn
}

# ============================================================
# Task Role — Mimir
# ============================================================

resource "aws_iam_role" "mimir_task" {
  name               = "${var.mimir_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.mimir_name}-task"
  }
}

data "aws_iam_policy_document" "mimir_task" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/ecs/${var.mimir_name}:*",
    ]
  }

  statement {
    sid    = "SSMExecuteCommand"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3MimirAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.mimir_bucket_name}",
      "arn:aws:s3:::${var.mimir_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "mimir_task" {
  name        = "${var.mimir_name}-task-policy"
  description = "Politica minima para a task role do Mimir."
  policy      = data.aws_iam_policy_document.mimir_task.json
}

resource "aws_iam_role_policy_attachment" "mimir_task" {
  role       = aws_iam_role.mimir_task.name
  policy_arn = aws_iam_policy.mimir_task.arn
}

# ============================================================
# Task Role — Tempo
# ============================================================

resource "aws_iam_role" "tempo_task" {
  name               = "${var.tempo_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name = "${var.tempo_name}-task"
  }
}

data "aws_iam_policy_document" "tempo_task" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/ecs/${var.tempo_name}:*",
    ]
  }

  statement {
    sid    = "SSMExecuteCommand"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3TempoAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.tempo_bucket_name}",
      "arn:aws:s3:::${var.tempo_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "tempo_task" {
  name        = "${var.tempo_name}-task-policy"
  description = "Politica minima para a task role do Tempo."
  policy      = data.aws_iam_policy_document.tempo_task.json
}

resource "aws_iam_role_policy_attachment" "tempo_task" {
  role       = aws_iam_role.tempo_task.name
  policy_arn = aws_iam_policy.tempo_task.arn
}
