variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

# ECS Variables
variable "ec2_ami" {
  description = "AMI ID for ECS EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for ECS EC2 instances"
  type        = string
}

variable "ecs_min_size" {
  description = "Minimum number of ECS instances"
  type        = number
}

variable "ecs_max_size" {
  description = "Maximum number of ECS instances"
  type        = number
}

variable "instance_class" {
  description = "Instance class for the RDS database"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS database in GB"
  type        = number
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

# variable "username" {
#   description = "Master username for the RDS database"
#   type        = string
# }

# variable "password" {
#   description = "Master password for the RDS database"
# }

variable "rds_secret_name" {
  description = "Secret for postgres"
}

variable "redis_secret_name" {
  description = "Secret for redis"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
}

variable "redis_num_nodes" {
  description = "Redis node count"
  type        = string
}

variable "multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  default     = false
}


variable "acm_certificate_arn" {
  description = "ARN of SSL certificate"
  type        = string
  # default     = "arn:aws:acm:eu-west-1:084296958340:certificate/1b02b371-3b6e-4861-9a30-82a09183b9fd"
}

variable "host_header" {
  description = "dns header to allow"
  type        = string
}

variable "AppType" {
  type = string
}
variable "RailsEnv" {
  type = string
}


#Rabbitmq variables

variable "host_instance_type" {
  description = "Instance type for the RabbitMQ broker"
  type        = string
  default     = "mq.t3.micro"
}

variable "deployment_mode" {
  description = "Deployment mode for the RabbitMQ broker (SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ)"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "mq_secret_name" {
  description = "Rabbitmq secret name"
  type        = string
}
