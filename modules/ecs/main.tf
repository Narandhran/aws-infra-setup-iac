resource "aws_ecs_cluster" "main" {
  name = "${var.env}-ecs-cluster"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.env}-ecs-instance-role"

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

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.env}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_policy_attachment" "ecs_instance_policy_attachment" {
  name       = "${var.env}-ecs-instance-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_launch_template" "ecs" {
  name          = "${var.env}-ecs-launch-template"
  instance_type = var.instance_type
  image_id = var.ec2_ami

  vpc_security_group_ids = [aws_security_group.ecs.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-ecs-instance"
    }
  }
}

resource "aws_lb_target_group" "ecs_target_group_1" {
  name        = "${var.env}-ecs-tg-1"
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
    Name = "${var.env}-ecs-tg-1"
  }
}

resource "aws_lb_target_group" "ecs_target_group_2" {
  name        = "${var.env}-ecs-tg-2"
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
    Name = "${var.env}-ecs-tg-2"
  }
}

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

  tag {
    key                 = "Name"
    value               = "${var.env}-ecs-asg"
    propagate_at_launch = true
  }
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group_1.arn
  }
}

# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = var.load_balancer_arn
#   port              = 443
#   protocol          = "HTTPS"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs_target_group_2.arn
#   }
# }

resource "aws_security_group" "ecs" {
  name        = "${var.env}-ecs-sg"
  description = "Security group for ECS tasks and instances"
  vpc_id      = var.vpc_id

  # Ingress: Allow traffic from ALB to ECS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.alb_security_group_id]  # ALB SG ID
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-ecs-sg"
    Environment = var.env
  }
}
