variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "project" {
  type = string
}

variable "internal" {
  type = bool
  default = true
}

variable "text-processing-tg-port" {
 type = number 
}

variable "dictionary-tg-port" {
  type = number
}

variable "user-data-tg-port" {
  type = number
}

variable "vpc_id" {
  type = string
}