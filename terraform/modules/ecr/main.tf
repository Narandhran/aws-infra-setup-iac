resource "aws_ecr_repository" "ecr" {
  name = "${var.env}-${var.project_name}-ecr-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.env
    Name        = "${var.env}-${var.project_name}-ecr-repo"
  }
}


resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
