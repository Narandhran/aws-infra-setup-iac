variable "env" {
  type        = string
  description = "Project environment (dev, qa, prod)"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "b1os-v1"
}

variable "daemon_image_url" {
  type        = string
  description = "ECR image url for daemon service"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS project region"
}
