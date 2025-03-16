resource "aws_ecs_cluster" "main" {
  name = "${var.env}-${var.project_name}-ecs-cluster"
}

# IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.env}-${var.project_name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

## RDS and Redis access for ECS
resource "aws_iam_policy" "ecs_rds_redis_policy" {
  name = "${var.env}-${var.project_name}-ecs-rds-redis-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds-db:connect"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "elasticache:DescribeCacheClusters",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_rds_redis_policy_attachment" {
  name       = "${var.env}-${var.project_name}-ecs-rds-redis-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = aws_iam_policy.ecs_rds_redis_policy.arn

  lifecycle {
    ignore_changes = [roles]
  }
}

# Add Policy for ECR Access
resource "aws_iam_policy" "ecs_ecr_policy" {
  name        = "${var.env}-${var.project_name}-ecs-ecr-policy"
  description = "Policy for ECS instances to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach ECR Policy to ECS Instance Role
resource "aws_iam_policy_attachment" "ecs_ecr_policy_attachment" {
  name       = "${var.env}-${var.project_name}-ecs-ecr-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = aws_iam_policy.ecs_ecr_policy.arn

  lifecycle {
    ignore_changes = [roles]
  }
}

# Attach Default ECS Role Policy
resource "aws_iam_policy_attachment" "ecs_instance_policy_attachment" {
  name       = "${var.env}-${var.project_name}-ecs-instance-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"

  lifecycle {
    ignore_changes = [roles]
  }
}

# Attach ECR read policy
resource "aws_iam_policy_attachment" "ecs_ecr_readonly_policy_attachment" {
  name       = "${var.env}-b1os-v1-ecs-ecr-readonly-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

  lifecycle {
    ignore_changes = [roles]
  }
}

# Attach secret manager policy
resource "aws_iam_policy_attachment" "ecs_secret_manager_policy_attachment" {
  name       = "${var.env}-b1os-v1-ecs-ecr-readonly-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"

  lifecycle {
    ignore_changes = [roles]
  }
}

# Attach session manager policy
resource "aws_iam_policy_attachment" "ec2-session-manager_policy_attachment" {
  name       = "${var.env}-b1os-v1-ec2-session-manager-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

  lifecycle {
    ignore_changes = [roles]
  }
}

# Instance Profile for ECS Instances
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.env}-${var.project_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# Launch Template for ECS Instances
resource "aws_launch_template" "ecs" {
  name          = "${var.env}-${var.project_name}-ecs-launch-template"
  instance_type = var.instance_type
  image_id      = var.ec2_ami

  vpc_security_group_ids = [aws_security_group.ecs.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(trimspace(<<-EOT
    #!/bin/bash
    echo "ECS_CLUSTER=${var.env}-${var.project_name}-ecs-cluster" > /etc/ecs/ecs.config
    echo "ECS_LOGLEVEL=info" >> /etc/ecs/ecs.config
  EOT
  ))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-${var.project_name}-ecs-instance"
    }
  }
}

# ALB Target Groups
resource "aws_lb_target_group" "ecs_target_group_1" {
  name                 = "${var.env}-${var.project_name}-ecs-tg-1"
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = "30"

  health_check {
    matcher             = "200,301,404"
    timeout             = 9
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    path                = "/"
  }

  tags = {
    Name = "${var.env}-${var.project_name}-ecs-tg-1"
  }
}

resource "aws_lb_target_group" "ecs_target_group_2" {
  name        = "${var.env}-${var.project_name}-ecs-tg-2"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.env}-${var.project_name}-ecs-tg-2"
  }
}

# Auto Scaling Group for ECS Instances
resource "aws_autoscaling_group" "ecs" {
  # name                = "${var.env}-${var.project_name}-ecs-asg"
  desired_capacity    = var.min_size
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  # target_group_arns = [aws_lb_target_group.ecs_target_group_1.arn, aws_lb_target_group.ecs_target_group_2.arn]

  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.env}-${var.project_name}-ecs-asg"
    propagate_at_launch = true
  }
}

# Http listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.ecs_target_group_1.arn

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group_1.arn
  }
}

# Security Group for ECS Instances
resource "aws_security_group" "ecs" {
  name        = "${var.env}-${var.project_name}-ecs-sg"
  description = "Security group for ECS tasks and instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id] # ALB SG ID
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id] # ALB SG ID
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-ecs-sg"
    Environment = var.env
  }
}

resource "aws_lb_listener_rule" "rules_in_lb_80" {
  listener_arn = aws_lb_listener.http_listener.arn
  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  condition {
    host_header {
      # values = ["dev.b1os.life", "dev-b1os-v1-alb-1966114276.eu-west-1.elb.amazonaws.com"]
      values = var.host_headers
    }
  }
}

resource "aws_lb_listener_rule" "rules_in_lb_443" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 6
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group_1.arn
  }

  condition {
    host_header {
      # values = ["dev.b1os.life", "dev-b1os-v1-alb-1966114276.eu-west-1.elb.amazonaws.com"]
      values = var.host_headers
    }
  }
}
