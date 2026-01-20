variable "project" {
  type = string
}

variable "cloud_watch_log_group_name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "text-processing-target-group-arn" {
  type = string
}

variable "dictionary-target-group-arn" {
  type = string
}