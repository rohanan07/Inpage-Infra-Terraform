resource "aws_cloudwatch_log_group" "main" {
  name = "${var.project}-cloudwatch-log-group"
  retention_in_days = 7
}