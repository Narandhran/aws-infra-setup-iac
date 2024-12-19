variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where RDS is deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
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
  type        = string
}

variable "ecs_cidr_blocks" {
  description = "Allowed CIDR blocks for RDS ingress"
  default     = ["10.0.0.0/16"] # Adjust based on your ECS cluster or application CIDR
}

variable "secret_postgres_cred" {
  description = "Postgres credentials"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  default     = false
}
