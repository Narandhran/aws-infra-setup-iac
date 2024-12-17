variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
