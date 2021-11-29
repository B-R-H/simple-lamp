resource "aws_ecr_repository" "registries" {
    count = length(var.registries)
  name                 = var.registries[count.index]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
      Name = var.registries[count.index]
      Enviroment = var.env-tag
  }
}