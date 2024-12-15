variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "secret_value" {
  description = "Value of the secret"
  type        = string
}
