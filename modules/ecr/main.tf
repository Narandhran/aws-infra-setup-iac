resource "aws_ecr_repository" "main" {
  name                 = "${var.env}-ecr-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.env
    Name        = "${var.env}-ecr-repo"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}
