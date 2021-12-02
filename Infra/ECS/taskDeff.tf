resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "nodeapp" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "nodeapp",
      "image": "${data.terraform_remote_state.ECR.outputs.registry_url[2]}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container-port},
          "hostPort": ${var.container-port}
        }
      ],
      "memory": ${tostring(var.container-memory)},
      "cpu": ${tostring(var.container-cpu)}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.container-memory         # Specifying the memory our container requires
  cpu                      = var.container-cpu         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_ecs_service" "my_first_service" {
  name            = "flamp-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = var.app-count # Setting the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.my_first_task.family}"
    container_port   = var.container-port # Specifying the container port
  }

  network_configuration {
    subnets          = aws_subnet.default_subnets.*.id
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}