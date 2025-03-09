# IAM Role for SSM and Secrets Manager Access
resource "aws_iam_role" "ssm_role" {
  name = "deamon-ec2-ssm-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach SSM Managed Policy
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Secrets Manager Policy
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets-manager-access-policy-${var.env}"
  description = "Allow EC2 to access AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecrets"
      ]
      Resource = "*"
    }]
  })
}

# Attach Secrets Manager Policy to IAM Role
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ec2-ssm-instance-profile-${var.env}"
  role = aws_iam_role.ssm_role.name
}

# Security Group (Optional: Limit Access)
resource "aws_security_group" "allow_ssm" {
  vpc_id      = var.vpc_id
  name        = "deamon-allow-ssm-${var.env}"
  description = "Allow SSM traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows SSM connection via HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instance with SSM and Secrets Manager Role
resource "aws_instance" "ec2_instance" {
  ami           = var.deamon_ami
  instance_type = var.deamon_instance_type

  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssm.id]
  subnet_id              = var.subnet_id_for_daemon_ec2


  user_data = <<-EOF
    #!/bin/bash
    # Add deploy to sudoers with no password prompt
    echo "deploy ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

    # Install required gems
    sudo gem install set -v "1.0.3"
    sudo gem install aws-sdk-secretsmanager

    # Set environment variables
    export AWS_REGION="${var.aws_region}"
    export RAILS_ENV="${var.rails_env}"
    export HOME=/home/deploy

    # Navigate to the application directory and run the startup script
    cd /home/deploy/app/b1os_ror
    sudo -E bash -c 'source /home/deploy/.rvm/scripts/rvm && ./ci-cd/startup.sh'
  EOF

  tags = {
    Name = "${var.env}-${var.project_name}-deamon-instance"
  }
}


resource "aws_security_group" "daemon_rds_sg" {
  vpc_id      = var.vpc_id
  description = "RDS security group allowing EC2 SG access"

  # Allow incoming connections from the EC2 security group on port 5432 (PostgreSQL)
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ssm.id] # Reference the EC2 security group
  }

  tags = {
    Name = "${var.env}-${var.project_name}-daemon-rds-sg"
  }
}
