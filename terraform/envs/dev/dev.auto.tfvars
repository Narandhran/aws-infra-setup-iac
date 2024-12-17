region = "eu-west-1"
env    = "dev"
project_name = "b1os-v1"

vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
availability_zones = ["eu-west-1a", "eu-west-1b"]

ec2_ami       = "ami-0df30dae7c89ce4d4"
instance_type = "t3.medium"
ecs_min_size  = 1
ecs_max_size  = 2

instance_class    = "db.t3.micro" # db.m7g.large
allocated_storage = 20
db_name           = "devdb"
username          = "user_admin"
password          = "asda8wewa9osadpnferuenvdadadad0acvflggjwe"
secret_postgres_cred = "dev/b1osv1/postgres"

redis_node_type = "cache.t3.micro"
# redis_num_nodes = 1
