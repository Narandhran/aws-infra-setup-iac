variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the resources will be created"
  type        = string
}

variable "ecs_cidr_blocks" {
  description = "CIDR blocks for ECS security group"
  type        = list(string)
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "node_type" {
  description = "Instance class for Redis (e.g., cache.t3.micro)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "num_cache_nodes" {
  description = "Cache node for redis"
  type        = string
}

variable "redis_secret_name" {
  description = "Secret for redis"
}
