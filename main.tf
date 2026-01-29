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
  private_subnet_ids = module.vpc.private_subnet_id
}

module "alb" {
  source = "./modules/alb"
  project = var.project
  vpc_id = module.vpc.vpc_id
  security_group_id = module.security.alb_sg_id
  text-processing-tg-port = var.text-processing-tg-port
  dictionary-tg-port = var.dictionary-tg-port
  user-data-tg-port = var.user-data-tg-port
  subnet_ids = module.vpc.public_subnet_id
}

module "iam" {
  source = "./modules/iam"
  project = var.project
  user_words_table_arn = module.dynamodb.user_words_table_arn
}

module "ecs" {
  source = "./modules/ecs"
  project = var.project
  cloud_watch_log_group_name = module.cloudwatch.cloud_watch_log_group_name
  task_role_arn = module.iam.task_role_arn
  execution_role_arn = module.iam.task_execution_role_arn
  text-processing-target-group-arn = module.alb.text_processing_target_group_arn
  dictionary-target-group-arn = module.alb.dictionary_target_group_arn
  security_group_id = module.security.ecs_sg_id
  private_subnets = module.vpc.private_subnet_id
  region = var.region
  alb_dns_name = module.alb.alb_dns_name
  user-data-target-group-arn = module.alb.user_data_target_group_arn
  user_words_table_name = module.dynamodb.user_words_table_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  project = var.project
}

module "lambda" {
  source = "./modules/lambda"
  project = var.project
  lambda_sg_id = module.security.lambda_sg_id
  private_subnet_ids = module.vpc.private_subnet_id
  api_orchestrator_role_arn = module.iam.api_orchestrator_role_arn
  environment = var.environment
  alb_dns_name = module.alb.alb_dns_name
  USER_DATA_SERVICE_URL = "http://${module.alb.alb_dns_name}/userdata"
}

module "cognito" {
  source = "./modules/cognito"
  project = var.project
  api_gateway_rest_api_id = module.apigateway.api_gateway_id
}

module "apigateway" {
  source = "./modules/apigateway"
  project = var.project
  lambda_function_invoke_arn = module.lambda.lambda_function_invoke_arn
  function_name = module.lambda.function_name
  authorizer_id = module.cognito.authorizer_id
}

module "dynamodb" {
  source = "./modules/dynamodb"
  project = var.project
  region = var.region
}