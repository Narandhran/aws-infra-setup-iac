# data "aws_secretsmanager_secret_version" "rds_secret" {
#   secret_id = var.secret_postgres_cred # Replace with your secret name or ARN
# }

# # Parse the secret JSON and extract username/password
# locals {
#   db_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)
# }


resource "aws_db_instance" "rds" {
  identifier        = "${var.env}-${var.project_name}-rds-instance"
  engine            = "postgres" # Use PostgreSQL engine
  engine_version    = "16.5"     # Optional: Specify the desired PostgreSQL version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  db_name           = var.db_name # Database name
  # username                   = local.db_credentials["username"] # Master username
  # password                   = local.db_credentials["password"] # Master password

  username                   = var.username
  password                   = var.password
  vpc_security_group_ids     = [aws_security_group.rds.id]
  db_subnet_group_name       = aws_db_subnet_group.rds.name # Subnet group for RDS
  backup_retention_period    = 7                            # Keep 7 days of backups
  maintenance_window         = "Mon:00:00-Mon:03:00"        # Maintenance time
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  tags = {
    Environment = var.env
    Name        = "${var.env}-${var.project_name}-rds-instance"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.env}-${var.project_name}-rds-subnet-group"
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
    Name        = "${var.env}-${var.project_name}-rds-sg"
    Environment = var.env
  }
}
