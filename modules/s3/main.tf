resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

output "bucket_name" {
  value       = aws_s3_bucket.bucket.id
  description = "Name of the created S3 bucket"
}

variable "instance_class" {
  description = "Instance class for Redis (e.g., cache.t3.micro)"
  type        = string
}
