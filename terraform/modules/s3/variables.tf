variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}
