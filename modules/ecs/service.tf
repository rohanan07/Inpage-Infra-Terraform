resource "aws_ecs_service" "text-processing-service" {
  name = "text-procesing-service"
  cluster = aws_ecs_cluster.inpage_cluster.id
  task_definition = aws_ecs_task_definition.text-processing-task-def.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "LATEST"
  enable_ecs_managed_tags = true

  network_configuration {
    subnets = var.private_subnets
    security_groups = [ var.security_group_id ]
    assign_public_ip = "DISABLED"
  }

  load_balancer {
    target_group_arn = var.text-processing-target-group-arn
    container_name = "text-processing-task"
    container_port = 3000
  }

  health_check_grace_period_seconds = 60
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
  
}

resource "aws_ecs_service" "dictionary-service" {
  name = "dictionary-service"
  cluster = aws_ecs_cluster.inpage_cluster.id
  task_definition = aws_ecs_task_definition.dictionary-task-def.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "LATEST"
  enable_ecs_managed_tags = true

  network_configuration {
    subnets = var.private_subnets
    security_groups = [ var.security_group_id ]
    assign_public_ip = "DISABLED"
  }

  load_balancer {
    target_group_arn = var.dictionary-target-group-arn
    container_name = "dictionary-task"
    container_port = 3000
  }
  
  health_check_grace_period_seconds = 60
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
}