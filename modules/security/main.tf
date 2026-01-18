resource "aws_security_group" "lambda-sg" {
  name = "${var.project}-lambda-sg"
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic"
  }
  tags = {
    Name = "lambda-sg"
  }
}

resource "aws_security_group" "alb-sg" {
  name = "${var.project}-alb-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    security_groups = [aws_security_group.lambda-sg.id]
    description = "Allow http traffic from lambda only"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs-sg" {
  name = "${var.project}-ecs-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "TCP"
    security_groups = [aws_security_group.alb-sg.id]
    description = "Allow http traffic only from internal alb"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic via nat"
  }
}