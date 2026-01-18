output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}
output "lambda_sg_id" {
  value = aws_security_group.lambda-sg.id
}
output "ecs_sg_id" {
  value = aws_security_group.ecs-sg.id
}