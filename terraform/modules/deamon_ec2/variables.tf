variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "deamon_ami" {
  type    = string
  default = "ami-058a16885888dcd8b"
}

variable "deamon_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "rails_env" {
  type    = string
  default = "development"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id_for_daemon_ec2" {}
