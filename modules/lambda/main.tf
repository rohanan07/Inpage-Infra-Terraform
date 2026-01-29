data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "api_orchestrator" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = "${var.project}api-orchestrator-function"
  role = var.api_orchestrator_role_arn
  handler = "index.handler"
  runtime = "nodejs18.x"
  timeout = 15
  vpc_config {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      ENVIRONMENT = var.environment
      ALB_DNS = var.alb_dns_name
      USER_DATA_SERVICE_URL = var.USER_DATA_SERVICE_URL
    }
  }
  tags = {
    name = "${var.project}-api-orchestrator-function"
  }
}