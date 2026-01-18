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