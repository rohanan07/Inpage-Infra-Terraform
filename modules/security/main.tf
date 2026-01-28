resource "aws_security_group" "lambda_sg" {
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

resource "aws_security_group" "ecs_sg" {
  name = "${var.project}-ecs-sg"
  vpc_id = var.vpc_id
  # ingress {
  #   from_port = 3000
  #   to_port = 3000
  #   protocol = "TCP"
  #   security_groups = [aws_security_group.alb-sg.id]
  #   description = "Allow http traffic only from internal alb"
  # }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic via nat"
  }
  tags = {
    Name = "${var.project}-ecs-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name = "${var.project}-alb-sg"
  vpc_id = var.vpc_id
  # ingress {
  #   from_port = 80
  #   to_port = 80
  #   protocol = "TCP"
  #   security_groups = [aws_security_group.lambda-sg.id, aws_security_group.ecs-sg.id]
  #   description = "Allow http traffic from lambda and ecs services"
  # }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}-alb-sg"
  }
}

resource "aws_security_group_rule" "lambda_to_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id         = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

resource "aws_security_group_rule" "ecs_to_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id         = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id         = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id
  subnet_ids = var.private_subnet_ids
  
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  
  egress {
    rule_no    = 90
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }


}