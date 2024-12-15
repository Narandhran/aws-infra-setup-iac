variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where Redis is deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for Redis"
  type        = list(string)
}

variable "redis_node_type" {
  description = "Node type for Redis"
  type        = string
}

variable "redis_num_nodes" {
  description = "Number of Redis nodes"
  type        = number
}
