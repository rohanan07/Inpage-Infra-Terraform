resource "aws_ecs_cluster" "inpage_cluster" {
 name = "${var.project}-cluster"
 setting {
   name = "containerInsights"
   value = "enabled"
 }
 configuration {
   execute_command_configuration {
     logging = "OVERRIDE"
     log_configuration {
       cloud_watch_encryption_enabled = true
       cloud_watch_log_group_name = var.cloud_watch_log_group_name
     }
   }
 }
 depends_on = [ var.cloud_watch_log_group_name ]
}