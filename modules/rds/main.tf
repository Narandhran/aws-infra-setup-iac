resource "aws_db_instance" "rds" {
  identifier             = "${var.env}-rds-instance"
  engine                 = "postgres"              # Use PostgreSQL engine
  engine_version         = "16.5"                 # Optional: Specify the desired PostgreSQL version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.name            # Database name
  username               = var.username        # Master username
  password               = var.password        # Master password
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name # Subnet group for RDS
  backup_retention_period = 7       # Keep 7 days of backups
  maintenance_window       = "Mon:00:00-Mon:03:00"  # Maintenance time
  auto_minor_version_upgrade = true

  tags = {
    Environment = var.env
    Name        = "${var.env}-rds-instance"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.env}-rds-subnet-group"
    Environment = var.env
  }
}


resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.ecs_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-rds-sg"
    Environment = var.env
  }
}