variable "env" {
  type        = string
  description = "Project environment (dev, qa, prod)"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "b1os-v1"
}

variable "AppType" {
  type = string
}

variable "RailsEnv" {
  type        = string
  description = "Rails environment"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS project region"
}

variable "target_group_1_arn" {
  type        = string
  description = "ARN of HTTP target group"
}

variable "B1osContainerCpu" {
  description = "CPU for ECS task and container"
}

variable "B1osContainerMemory" {
  description = "Memory for ECS task and container"
}

variable "B1osImage" {
  type        = string
  description = "ECR image name with the tag"
}

variable "desire_ecs_task" {
  type        = number
  description = "Desired ECS task count across AZ"
  default     = 4
}

variable "ClusterName" {
  type        = string
  description = "ECS cluster name"
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}
variable "ecs_security_group_id" {
  type    = string
  default = ""
}
