output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "api_orchestrator_role_arn" {
  value = aws_iam_role.api_orchestrator_role.arn
}