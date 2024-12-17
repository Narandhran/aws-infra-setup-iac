output "redis_endpoint" {
  value       = aws_elasticache_cluster.redis.configuration_endpoint
  description = "The endpoint of the Redis cluster"
}
