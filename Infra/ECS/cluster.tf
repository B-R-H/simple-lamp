resource "aws_ecs_cluster" "my_cluster" {
  name = "flamp-cluster"
  tags = {
    Name = "flamp-cluster"
    Enviroment = var.env-tag
  }
}