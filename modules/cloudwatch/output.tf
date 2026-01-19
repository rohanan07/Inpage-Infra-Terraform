output "cloud_watch_log_group_name" {
  description = "name of the cloudwatch log group"
  value = aws_cloudwatch_log_group.main.name
}