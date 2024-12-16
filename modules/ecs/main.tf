resource "aws_ecs_cluster" "main" {
  name = "${var.env}-ecs-cluster"
}

resource "aws_launch_template" "ecs" {
  name          = "${var.env}-ecs-launch-template"
  instance_type = var.instance_type
  image_id = var.ec2_ami

  vpc_security_group_ids = [aws_security_group.ecs.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-ecs-instance"
    }
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

  tag {
    key                 = "Name"
    value               = "${var.env}-ecs-asg"
    propagate_at_launch = true
  }
}


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
