# CloudWatch Log Group for ECS Task
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name              = "/ecs/${var.env}-${var.project_name}-ecs-task"
  retention_in_days = 14
}

#task definition
resource "aws_ecs_task_definition" "web" {
  family                   = "${var.env}-${var.project_name}-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = var.B1osContainerCpu
  memory                   = var.B1osContainerMemory



  container_definitions = jsonencode([
    {
      "name" : "b1os-v1-web-container",
      "image" : "${var.B1osImage}",
      "cpu" : 1024,
      "memory" : 1024,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 3000,
          # "hostPort" : 0,
          "protocol" : "tcp"
        }
      ],
      "mountPoints" : [
        {
          "containerPath" : "/app/log",
          "sourceVolume" : "app-logs-volume"
        },
        {
          "containerPath" : "/app/nginx/logs",
          "sourceVolume" : "nginx-logs-volume"
        }
      ],
      "environment" : [
        {
          "name" : "ENVIRONMENT",
          "value" : "${var.env}"
        },
        {
          "name" : "PROJECT_NAME",
          "value" : "${var.project_name}"
        },
        {
          "name" : "APP_TYP",
          "value" : "${var.AppType}"
        },
        {
          "name" : "RAILS_ENV",
          "value" : "${var.RailsEnv}"
        },
        {
          "name" : "AWS_REGION",
          "value" : "${var.region}"
        }
      ],

      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.ecs_task_logs.name}",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])

  volume {
    name      = "app-logs-volume"
    host_path = "/apps/b1os/logs"
  }

  volume {
    name      = "nginx-logs-volume"
    host_path = "/apps/b1os/nginx"
  }

  depends_on = [aws_cloudwatch_log_group.ecs_task_logs]

}

resource "aws_ecs_service" "web" {
  name                    = "${var.env}-${var.project_name}-service"
  cluster                 = var.ClusterName
  launch_type             = "EC2"
  task_definition         = aws_ecs_task_definition.web.arn
  enable_ecs_managed_tags = true
  desired_count           = var.desire_ecs_task # Number of tasks to run across AZs

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100
  wait_for_steady_state              = false
  health_check_grace_period_seconds  = 500

  network_configuration {
    subnets         = var.private_subnet_ids # Use all private subnets
    security_groups = [var.ecs_security_group_id]
  }

  force_new_deployment = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone =~ .*"
  }

  # Register each ECS task with ALB
  load_balancer {
    target_group_arn = var.target_group_1_arn
    container_name   = "b1os-v1-web-container"
    container_port   = 3000 # ALB will route to the container
  }

  depends_on = [aws_ecs_task_definition.web]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4 * 2 # Max ECS tasks (2 per EC2)
  min_capacity       = 2 * 2 # Min ECS tasks (2 per EC2)
  resource_id        = "service/${var.ClusterName}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_target_tracking" {
  name               = "ecs-auto-scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50.0 # AWS auto-scales up/down based on this value
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300 # Wait 5 minutes before scaling down
    scale_out_cooldown = 120 # Wait 2 minutes before scaling up
  }
}

