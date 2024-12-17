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
}

# Attach Default ECS Role Policy
resource "aws_iam_policy_attachment" "ecs_instance_policy_attachment" {
  name       = "${var.env}-${var.project_name}-ecs-instance-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
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

  user_data = base64encode(<<-EOT
    #!/bin/bash
    echo "ECS_CLUSTER=${var.env}-${var.project_name}-ecs-cluster" > /etc/ecs/ecs.config
    yum install -y aws-cli ecs-init
    systemctl enable ecs
    systemctl start ecs
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-${var.project_name}-ecs-instance"
    }
  }
}

# ALB Target Groups
resource "aws_lb_target_group" "ecs_target_group_1" {
  name        = "${var.env}-${var.project_name}-ecs-tg-1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
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
  target_type = "instance"

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
  desired_capacity    = var.min_size
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.ecs_target_group_1.arn, aws_lb_target_group.ecs_target_group_2.arn]

  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.env}-${var.project_name}-ecs-asg"
    propagate_at_launch = true
  }
}

# ALB Listeners
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

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

# CloudWatch Log Group for ECS Task
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name              = "/ecs/${var.env}-${var.project_name}-ecs-task"
  retention_in_days = 14
}
