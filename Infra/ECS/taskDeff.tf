resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "flampapp"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "flampapp",
      "image": "${data.terraform_remote_state.ECR.outputs.registry_url[0]}",
      "environment": [
        {
        "name": "DATABASE_URL",
        "value": "test"
        }
      ],
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container-port[0]},
          "hostPort": ${var.container-port[0]}
        }
      ],
      "memory": ${tostring(var.container-memory[0])},
      "cpu": ${tostring(var.container-cpu[0])}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.container-memory[0]   
  cpu                      = var.container-cpu[0]
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  tags = {
    Name = "flampTask"
    Enviroment = var.env-tag
  }
}

resource "aws_ecs_task_definition" "database" {
  family                   = "database"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "database",
      "image": "${data.terraform_remote_state.ECR.outputs.registry_url[1]}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container-port[1]},
          "hostPort": ${var.container-port[1]}
        }
      ],
      "environment": [
        {
        "name": "MYSQL_RANDOM_ROOT_PASSWORD",
        "value": "true"
        }
      ],
      "memory": ${tostring(var.container-memory[1])},
      "cpu": ${tostring(var.container-cpu[1])}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.container-memory[1]   
  cpu                      = var.container-cpu[1]
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  tags = {
    Name = "databaseTask"
    Enviroment = var.env-tag
  }
}

resource "aws_ecs_service" "my_first_service" {
  name            = "lamp-service"
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = var.app-count

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.my_first_task.family}"
    container_port   = var.container-port[0] # Specifying the container port
  }

  network_configuration {
    subnets          = aws_subnet.default_subnets.*.id
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
  tags = {
    Name = "lampService"
    Enviroment = var.env-tag
  }
}

resource "aws_ecs_service" "database_service" {
  name            = "database-service"
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.database.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.default_subnets.*.id
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
  tags = {
    Name = "databaseService"
    Enviroment = var.env-tag
  }
}