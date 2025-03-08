variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

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

variable "vpc_id" {
  description = "ID of the VPC where RDS is deployed"
  type        = string
}

variable "subnet_ids" {}
variable "mq_single_subnet_id" {}
