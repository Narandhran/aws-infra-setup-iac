resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-redis-cluster"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_nodes
  parameter_group_name = "default.redis6.x"
  subnet_group_name    = aws_elasticache_subnet_group.main.name
}
