resource "aws_cognito_user_pool" "users" {
  name = "${var.project}-user-pool" 
  username_attributes = [ "email" ]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
  }
  tags = {
    name = "${var.project}-user-pool"
  }
}

resource "aws_cognito_user_pool_client" "android_client" {
  name = "${var.project}-client"
  user_pool_id = aws_cognito_user_pool.users.id
  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH", 
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name = "${var.project}-apigateway-authorizer"
  rest_api_id = var.api_gateway_rest_api_id
  type = "COGNITO_USER_POOLS"
  provider_arns = [ aws_cognito_user_pool.users.arn ]
}