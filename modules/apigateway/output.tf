output "api_gateway_id" {
  value = aws_api_gateway_rest_api.inpage_api.id
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.dev.invoke_url
}