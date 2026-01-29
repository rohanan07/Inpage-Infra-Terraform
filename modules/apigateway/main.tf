resource "aws_api_gateway_rest_api" "inpage_api" {
  name = "${var.project}-api"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

resource "aws_api_gateway_resource" "process" {
  parent_id = aws_api_gateway_rest_api.inpage_api.root_resource_id
  path_part = "process"
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
}

resource "aws_api_gateway_method" "process_post" {
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
  request_parameters = {
    "method.request.header.Authorization" = true
  }
  http_method = "POST"
  resource_id = aws_api_gateway_resource.process.id
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
}

resource "aws_api_gateway_integration" "process_integration" {
  http_method = aws_api_gateway_method.process_post.http_method
  resource_id = aws_api_gateway_resource.process.id
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = var.lambda_function_invoke_arn
}

resource "aws_api_gateway_resource" "dictionary" {
  parent_id = aws_api_gateway_rest_api.inpage_api.root_resource_id
  path_part = "dictionary"
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
}

resource "aws_api_gateway_method" "dictionary_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.dictionary.id
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
}

resource "aws_api_gateway_integration" "dictionary_integration" {
  http_method = aws_api_gateway_method.dictionary_get.http_method
  resource_id = aws_api_gateway_resource.dictionary.id
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = var.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.inpage_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
  triggers = {
    redeployment = sha1(jsonencode([
        aws_api_gateway_resource.process.id,
        aws_api_gateway_resource.dictionary.id,
        aws_api_gateway_integration.process_integration.id,
        aws_api_gateway_integration.dictionary_integration.id,
        aws_api_gateway_method.process_post.id,
        aws_api_gateway_method.dictionary_get.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ 
    aws_api_gateway_integration.dictionary_integration, 
    aws_api_gateway_integration.process_integration 
  ]
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id = aws_api_gateway_rest_api.inpage_api.id
  stage_name = "dev"
}