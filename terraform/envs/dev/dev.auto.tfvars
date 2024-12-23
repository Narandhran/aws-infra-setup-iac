env          = "dev"
project_name = "b1os-v1"

#VPC
region             = "eu-west-1"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
availability_zones = ["eu-west-1a", "eu-west-1b"]

#ECS
ec2_ami             = "ami-000ccf3b2856b395e"
instance_type       = "t3.medium"
ecs_min_size        = 2
ecs_max_size        = 4
acm_certificate_arn = "arn:aws:acm:eu-west-1:084296958340:certificate/1b02b371-3b6e-4861-9a30-82a09183b9fd"
ecr_image_url       = "084296958340.dkr.ecr.eu-west-1.amazonaws.com/dev-ecr-repo:latest"

#RDS
instance_class       = "db.t3.micro"
allocated_storage    = 20
db_name              = "devdb"
secret_postgres_cred = "dev/b1osv1/postgres"
multi_az             = false

#Redis
redis_node_type = "cache.t3.micro"
redis_num_nodes = 1
