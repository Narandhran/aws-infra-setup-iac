variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where RDS is deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database in GB"
  type        = number
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
}

variable "ecs_cidr_blocks" {
  description = "Allowed CIDR blocks for RDS ingress"
  default     = ["10.0.0.0/16"]  # Adjust based on your ECS cluster or application CIDR
}