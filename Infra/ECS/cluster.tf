resource "aws_ecs_cluster" "lamp" {
  name = "lampCluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "lampCluster"
    Enviroment = var.env-tag
  }
}