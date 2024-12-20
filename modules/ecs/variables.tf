variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS is deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ec2_ami" {
  description = "AMI ID for ECS EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ECS"
  type        = string
}

variable "min_size" {
  description = "Minimum number of ECS instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of ECS instances"
  type        = number
}

variable "alb_security_group_id" {
  description = "ALB security group id"
  type        = string
}

variable "load_balancer_arn" {
  description = "ARN for load balancer"
  type        = string
}

variable "ecr_image_url" {
  description = "The URL of the ECR image to pull"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
