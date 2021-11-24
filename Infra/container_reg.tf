resource "aws_ecr_repository" "main-register" {
  name                 = "main-register"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
      Name = "mainreg"
      Enviroment = var.env-tag
  }
}