# 👇 Pull VPC/subnets from infra's remote state
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "bckt-tf-state-b1os"
    key    = "dev/eu-west-1/terraform.tfstate"
    region = "eu-west-1"
  }
}

#  ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.project_name}-ecs-cluster-daemon"
}

#  IAM Execution Role (for ECS itself - pulling image, logging)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoleForDaemon"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#  IAM Task Role (for your app container to access AWS resources)
resource "aws_iam_role" "ecs_task_app_role" {
  name = "ecsAppRoleForDaemon"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_app_policy" {
  name = "ecs-app-policy"
  role = aws_iam_role.ecs_task_app_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "kms:Decrypt"
        ],
        Resource = "*" #  You can restrict this to specific ARNs later
      }
    ]
  })
}

#  CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name              = "/ecs/${var.env}-${var.project_name}-daemon-task"
  retention_in_days = 14
}

#  ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env}-${var.project_name}-daemon-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_app_role.arn #  App's AWS access

  container_definitions = jsonencode([
    {
      name      = "${var.env}-${var.project_name}-daemon-container"
      image     = var.daemon_image_url
      essential = true

      # Health check
      healthCheck = {
        command     = ["CMD-SHELL", "pgrep -f 'rake daemons:start' || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 180
      }

      environment = [
        {
          name  = "RUN_RAKE_DAEMONS"
          value = "true"
        },
        {
          name  = "RAILS_ENV"
          value = "development"
        },
        {
          name  = "AWS_REGION"
          value = "eu-west-1"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : "${aws_cloudwatch_log_group.ecs_task_logs.name}",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

#  Security Group
resource "aws_security_group" "app_sg" {
  name        = "daemon-app-sg-${var.env}"
  description = "Allow HTTP"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#  Fargate ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "${var.env}-${var.project_name}-daemon-service"
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.app.arn

  network_configuration {
    subnets          = data.terraform_remote_state.infra.outputs.private_subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.app_sg.id]
  }
}
