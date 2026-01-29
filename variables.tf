variable "region" {
  type = string
  default = "ap-south-1"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "vpc_cidr" {
  type = string
  default = "10.2.0.0/16"
}

variable "public_subnets_cidr" {
  type = list(string)
  default = [ "10.2.1.0/24", "10.2.2.0/24" ]
}

variable "private_subnets_cidr" {
  type = list(string)
  default = [ "10.2.3.0/24", "10.2.4.0/24" ]
}

variable "availability_zones" {
  type = list(string)
  default = [ "ap-south-1a", "ap-south-1b" ]
}

variable "project" {
  type = string
  default = "Inpage"
}

variable "internal" {
  type = bool
  default = true
}

variable "text-processing-tg-port" {
 type = number
 default = 3000 
}

variable "dictionary-tg-port" {
  type = number
  default = 3000
}

variable "user-data-tg-port" {
  type = number
  default = 3000
}