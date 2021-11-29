resource "aws_ecs_cluster" "lamp" {
  name = "lampCluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name       = "lampCluster"
    Enviroment = var.env-tag
  }
}

resource "aws_ecs_service" "flamp" {
  name               = "flamp-service"
  cluster            = aws_ecs_cluster.lamp.id
  task_definition    = aws_ecs_task_definition.flamp.arn
  desired_count      = var.app-count
  launch_type        = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.flamp_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lamp.id
    container_name   = "lamp-app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.lamp]
}
