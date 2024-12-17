resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-${var.project_name}-redis-cluster"
  engine               = "redis"
  engine_version       = "6.2"
  node_type            = var.node_type # Example: "cache.t3.micro"
  num_cache_nodes      = 1                  # Single-node
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
