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