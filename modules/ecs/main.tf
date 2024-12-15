resource "aws_ecs_cluster" "main" {
  name = "${var.env}-ecs-cluster"
}

resource "aws_launch_configuration" "ecs" {
  name          = "${var.env}-ecs-launch-config"
  image_id      = var.ec2_ami
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  launch_configuration = aws_launch_configuration.ecs.id
  vpc_zone_identifier  = var.private_subnets
  min_size             = var.min_size
  max_size             = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.env}-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
}

