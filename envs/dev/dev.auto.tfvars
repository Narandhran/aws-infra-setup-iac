# region = "eu-west-1"
env    = "dev"

vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
availability_zones = ["eu-west-1a", "eu-west-1b"]

ec2_ami       = "ami-01c91b58dde35c59c"
instance_type = "t3.medium"
ecs_min_size  = 1
ecs_max_size  = 2

instance_class    = "db.t3.micro" # db.m7g.large
allocated_storage = 20
name              = "devdb"
username          = "dev_admin"
password          = "dev_password123"

# redis_node_type = "cache.t3.micro"
# redis_num_nodes = 1
