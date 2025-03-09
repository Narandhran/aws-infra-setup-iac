# IAM Role for SSM Access
resource "aws_iam_role" "ssm_role" {
  name = "deamon-ec2-ssm-role"

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

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# Security Group (Optional: Limit Access)
resource "aws_security_group" "allow_ssm" {
  name        = "deamon-allow-ssm"
  description = "Allow SSM traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can skip this since SSM doesn't need SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instance with SSM Role
resource "aws_instance" "ec2_instance" {
  ami           = var.deamon_ami
  instance_type = var.deamon_instance_type

  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssm.id]

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

    # Navigate to the application directory and run the startup script
    cd /home/deploy/app/b1os_ror
    sudo -E bash -c 'source /home/deploy/.rvm/scripts/rvm && ./ci-cd/startup.sh'
  EOF

  tags = {
    Name = "${var.env}-${var.project_name}-deamon-instance"
  }
}
