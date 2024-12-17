output "redis_endpoint" {
  value       = aws_elasticache_cluster.redis.configuration_endpoint
  description = "The endpoint of the Redis cluster"
}

variable "instance_class" {
  description = "Instance class for Redis (e.g., cache.t3.micro)"
  type        = string
}
