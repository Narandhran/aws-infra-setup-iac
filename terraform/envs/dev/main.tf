# Call VPC module
module "vpc" {
  source = "../../modules/vpc"

  env                = var.env
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  project_name       = var.project_name
}

# Call ALB module
module "alb" {
  project_name   = var.project_name
  source         = "../../modules/alb"
  env            = var.env
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
}

# Call ECS module
module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  env                   = var.env
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  private_subnets       = module.vpc.private_subnet_ids
  ec2_ami               = var.ec2_ami
  load_balancer_arn     = module.alb.alb_arn
  instance_type         = var.instance_type
  min_size              = var.ecs_min_size
  max_size              = var.ecs_max_size
  ##
  ecr_image_url = "084296958340.dkr.ecr.eu-west-1.amazonaws.com/${var.env}-ecr-repo:latest" # Replace with your ECR image URI
}

# Call RDS module
module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  env                  = var.env
  vpc_id               = module.vpc.vpc_id
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  private_subnet_ids   = module.vpc.private_subnet_ids
  ecs_cidr_blocks      = module.vpc.private_subnets_cidr
  secret_postgres_cred = var.secret_postgres_cred
}


# # Call Redis module
module "redis" {
  source = "../../modules/redis"

  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  ecs_cidr_blocks    = module.vpc.private_subnets_cidr
  env                = var.env
  node_type     = var.redis_node_type # Adjust instance type as needed
}



# Call ECR module
module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  env          = var.env
}

# # Call S3 module
# module "s3" {
#   source       = "../../modules/s3"
#   env          = var.env
#   bucket_name  = "${var.env}-${var.project_name}-app-bucket" # Provide the bucket name
# }

