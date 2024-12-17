resource "aws_secretsmanager_secret" "secret" {
  name        = var.secret_name
  description = "Secret for ${var.env} environment"

  tags = {
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_value
}

output "secret_arn" {
  value = aws_secretsmanager_secret.secret.arn
  description = "ARN of the created secret"
}
