# data "aws_secretsmanager_secret_version" "rds_secret" {
#   secret_id = var.secret_postgres_cred # Replace with your secret name or ARN
# }

# # Parse the secret JSON and extract username/password
# locals {
#   db_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)
# }

# Generate a random password
resource "random_password" "db_password" {
  length           = 16                      # Length of the password
  special          = false                   # Include special characters
  upper            = true                    # Include uppercase letters
  lower            = true                    # Include lowercase letters
  override_special = "!@#$%^&*()-_=+[]{}<>?" # Optional: Define allowed special characters
}


resource "aws_db_instance" "rds" {
  identifier        = "${var.env}-${var.project_name}-rds-instance"
  engine            = "postgres" # Use PostgreSQL engine
  engine_version    = "16.5"     # Optional: Specify the desired PostgreSQL version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  db_name           = var.db_name                        # Database name
  username          = "admin_user"                       # Master username
  password          = random_password.db_password.result # Master password

  # username                   = var.username
  # password                   = var.password
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

  # Availability Zone Configuration
  multi_az = var.multi_az # Enable or disable multi-AZ deployment
  # depends_on = [data.aws_secretsmanager_secret_version.rds_secret]

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


# Create the Secrets Manager secret
resource "aws_secretsmanager_secret" "db_secret" {
  name        = var.rds_secret_name
  description = "Database credentials for the ${var.env}-${var.project_name} RDS instance"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username             = "admin_user", # Replace with the hardcoded username or variable
    password             = random_password.db_password.result,
    engine               = "postgres", # Replace with the hardcoded value or variable
    host                 = aws_db_instance.rds.address,
    port                 = aws_db_instance.rds.port,
    dbname               = var.db_name, # Replace with your variable for DB name
    dbInstanceIdentifier = aws_db_instance.rds.identifier
  })
}

