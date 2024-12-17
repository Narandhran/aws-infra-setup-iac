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

variable "username" {
  description = "Master username for the RDS database"
  type        = string
}

variable "password" {
  description = "Master password for the RDS database"
}

variable "secret_postgres_cred" {
  description = "Secret for postgres"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
}
