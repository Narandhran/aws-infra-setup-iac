resource "random_password" "mq_password" {
  length           = 16                      # Length of the password
  special          = false                   # Include special characters
  upper            = true                    # Include uppercase letters
  lower            = true                    # Include lowercase letters
  override_special = "!@#$%^&*()-_=+[]{}<>?" # Optional: Define allowed special characters
}

resource "aws_security_group" "mq_sg" {
  name        = "${var.env}-${var.project_name}-mq-security-group"
  description = "Allow RabbitMQ access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_mq_broker" "rabbitmq_broker" {
  broker_name        = "${var.project_name}-${var.env}-mqbroker"
  engine_type        = "RabbitMQ"
  engine_version     = "3.12.13"              # Check for the latest supported version
  host_instance_type = var.host_instance_type # For development environment
  deployment_mode    = var.deployment_mode    # Use ACTIVE_STANDBY_MULTI_AZ for production

  publicly_accessible = true

  configuration {
    id       = aws_mq_configuration.rabbitmq_tls_config.id
    revision = aws_mq_configuration.rabbitmq_tls_config.latest_revision
  }

  #   security_groups = [aws_security_group.mq_sg.id]
  subnet_ids = var.deployment_mode == "SINGLE_INSTANCE" ? [var.mq_single_subnet_id] : var.subnet_ids

  user {
    username = "${var.env}_user"
    password = random_password.mq_password.result # Replace with a secure password
  }

  maintenance_window_start_time {
    day_of_week = "MONDAY"
    time_of_day = "02:00"
    time_zone   = "UTC"
  }

  logs {
    general = true
    audit   = false
  }

  tags = {
    Environment = var.env
    Name        = "${var.env}-${var.project_name}-rabbitmq-instance"
  }

  depends_on = [aws_mq_configuration.rabbitmq_tls_config]
}

resource "aws_mq_configuration" "rabbitmq_tls_config" {
  name           = "${var.project_name}-${var.env}-mq-config"
  engine_type    = "RabbitMQ"
  engine_version = "3.12.13"

  data = <<EOT
auth_mechanisms.1 = "PLAIN"
auth_mechanisms.2 = "AMQPLAIN"
ssl_options.verify = "verify_none"
ssl_options.fail_if_no_peer_cert = false
EOT

  tags = {
    Environment = var.env
    Name        = "${var.env}-${var.project_name}-rabbitmq-config"
  }
}


# Create the Secrets Manager secret
resource "aws_secretsmanager_secret" "mq_secret" {
  name        = var.mq_secret_name
  description = "Rabbitmq credentials for the ${var.env} instance"
}

resource "aws_secretsmanager_secret_version" "mq_secret_version" {
  secret_id = aws_secretsmanager_secret.mq_secret.id
  secret_string = jsonencode({
    username   = "${var.env}_user", # Replace with the hardcoded username or variable
    password   = random_password.mq_password.result,
    broker_url = aws_mq_broker.rabbitmq_broker.id
  })
}
