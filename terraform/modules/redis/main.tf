resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-${var.project_name}-redis-cluster"
  engine               = "redis"
  engine_version       = "6.2"
  node_type            = var.node_type # Example: "cache.t3.micro"
  num_cache_nodes      = var.num_cache_nodes
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  parameter_group_name = "default.redis6.x" # Adjust based on your Redis version
  port                 = 6379

  tags = {
    Name        = "${var.env}-${var.project_name}-redis-cluster"
    Environment = var.env
  }
}


resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.env}-${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.env}-${var.project_name}-redis-subnet-group"
    Environment = var.env
  }
}

resource "aws_security_group" "redis" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.ecs_cidr_blocks # Allow ECS to connect
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-${var.project_name}-redis-sg"
    Environment = var.env
  }
}


# Create the Secrets Manager secret
resource "aws_secretsmanager_secret" "redis_secret" {
  name        = var.redis_secret_name
  description = "Credentials for the ${var.env}-${var.project_name} redis instance"
}

# Store Redis connection details in Secrets Manager
resource "aws_secretsmanager_secret_version" "redis_secret_version" {
  secret_id = aws_secretsmanager_secret.redis_secret.id
  secret_string = jsonencode({
    host = aws_elasticache_cluster.redis.cache_nodes[0].address # Retrieve the primary node's address
    port = tostring(aws_elasticache_cluster.redis.port)         # Retrieve the Redis port
    db   = "0"                                                  # Default Redis DB
  })
}
