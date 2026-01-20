resource "aws_ecs_task_definition" "text-processing-task-def" {
  family = "${var.project}-text-processing-task-def"
  requires_compatibilities = [ "FARGATE" ]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
  container_definitions = jsonencode([{
    name = "text-processing-task"
    image = "nginx:latest"
    cpu = 0
    memory = 512
    essential = true
    portMappings = [
      {
        containerPort = 3000
        hostPort = 3000
        protocol = "tcp"
      }
    ]
    environment = [
      {
        name = "SERVICE_NAME"
        value = "text-processing"
      },
      {
        name = "ENV"
        value = "dev"
      }
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group" = var.cloud_watch_log_group_name
        "awslogs-region" = var.region
        "awslogs-stream-prefix" = "text-processing"
      }
    }
    }
  ])
}

resource "aws_ecs_task_definition" "dictionary-task-def" {
  family = "${var.project}-dictionary-task-def"
  requires_compatibilities = [ "FARGATE" ]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
  container_definitions = jsonencode([{
    name = "dictionary-task"
    image = "nginx:latest"
    cpu = 0
    memory = 512
    essential = true
    portMappings = [
      {
        containerPort = 3000
        hostPort = 3000
        protocol = "tcp"
      }
    ]
    environment = [
      {
        name = "SERVICE_NAME"
        value = "dictionary"
      },
      {
        name = "ENV"
        value = "dev"
      }
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group" = var.cloud_watch_log_group_name
        "awslogs-region" = var.region
        "awslogs-stream-prefix" = "dictionary"
      }
    }
    }
  ])
}