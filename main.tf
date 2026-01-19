module "vpc" {
  source = "./modules/vpc"
  project = var.project
  vpc_cidr = var.vpc_cidr
  private_subnets_cidr = var.private_subnets_cidr
  public_subnets_cidr = var.public_subnets_cidr
  availability_zones = var.availability_zones
}

module "security" {
  source = "./modules/security"
  project = var.project
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"
  project = var.project
  vpc_id = module.vpc.vpc_id
  security_group_id = module.security.alb_sg_id
  text-processing-tg-port = var.text-processing-tg-port
  dictionary-tg-port = var.dictionary-tg-port
  subnet_ids = module.vpc.public_subnet_id
}

module "iam" {
  source = "./modules/iam"
  project = var.project
}

module "ecs" {
  source = "./modules/ecs"
  project = var.project
  cloud_watch_log_group_name = module.cloudwatch.cloud_watch_log_group_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  project = var.project
}