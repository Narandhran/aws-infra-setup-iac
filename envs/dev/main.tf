# Call VPC module
module "vpc" {
  source = "../../modules/vpc"

  env                = var.env
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# Call ALB module
module "alb" {
  source = "../../modules/alb"
  env             = var.env
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
}

# Call ECS module
module "ecs" {
  source = "../../modules/ecs"

  env                = var.env
  vpc_id             = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  private_subnets    = module.vpc.private_subnet_ids
  ec2_ami            = var.ec2_ami
  load_balancer_arn = module.alb.alb_arn
  instance_type      = var.instance_type
  min_size           = var.ecs_min_size
  max_size           = var.ecs_max_size
}

# Call RDS module
module "rds" {
  source               = "../../modules/rds"
  env                  = var.env
  vpc_id               = module.vpc.vpc_id
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  name                 = var.name
  username             = var.username
  password             = var.password
  private_subnet_ids   = module.vpc.private_subnet_ids
  ecs_cidr_blocks = module.vpc.private_subnets_cidr

}


# # Call Redis module
module "redis" {
  source              = "../../modules/redis"
  private_subnet_ids  = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  ecs_cidr_blocks     = module.vpc.private_subnets_cidr
  env                 = var.env
  instance_class      = "cache.t3.micro"  # Adjust instance type as needed
}



# Call ECR module
module "ecr" {
  source = "../../modules/ecr"

  env = var.env
}

# # Call S3 module
# module "s3" {
#   source       = "../../modules/s3"
#   env          = var.env
#   bucket_name  = "${var.env}-app-bucket" # Provide the bucket name
# }


# resource "aws_ecs_task_definition" "hello_world_task" {
#   family                   = "${var.env}-hello-world-task"
#   network_mode             = "bridge"
#   requires_compatibilities = ["EC2"]
#   cpu                      = "512"
#   memory                   = "512"

#   container_definitions = jsonencode([{
#     name      = "hello-world-container"
#     image     = "084296958340.dkr.ecr.eu-west-1.amazonaws.com/dev-ecr-repo:latest"
#     # memory    = 512
#     essential = true
#     cpu       = 256
    
#     portMappings = [{
#       containerPort = 80
#       hostPort      = 0
#       protocol      = "tcp"
#     }]
#   }])
# }


# resource "aws_ecs_service" "hello_world_service" {
#   name            = "${var.env}-hello-world-service"
#   cluster         = module.ecs.ecs_cluster_name
#   task_definition = aws_ecs_task_definition.hello_world_task.arn
#   desired_count   = 1
#   launch_type     = "EC2"

#   load_balancer {
#     # target_group_arn = aws_alb_target_group.main.arn
#     target_group_arn = module.ecs.alb_target_group_arn
#     container_name   = "hello-world-container"
#     container_port   = 80
#   }

#   deployment_minimum_healthy_percent = 50
#   deployment_maximum_percent         = 200
  
#   lifecycle {
#     ignore_changes = [desired_count]
#   }
# }
