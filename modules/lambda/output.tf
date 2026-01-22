output "function_name" {
  value = aws_lambda_function.api_orchestrator.function_name
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.api_orchestrator.invoke_arn
}