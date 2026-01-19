resource "aws_lb" "main_alb" {
  name = "${var.project}-internal-alb"
  load_balancer_type = "application"
  internal = var.internal
  security_groups = [ var.security_group_id ]
  subnets = var.subnet_ids
  enable_cross_zone_load_balancing = true
  idle_timeout = 90
  ip_address_type = "ipv4"
  tags = {
    name = "${var.project}-internal-alb"
  }
}

resource "aws_lb_target_group" "text-processing-tg" {
  name = "${var.project}-text-processing-tg"
  port = var.text-processing-tg-port
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"

  health_check {
    enabled = true
    path = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
  deregistration_delay = 30
  
  tags = {
    name = "${var.project}-text-processing-tg"
  }
}

resource "aws_lb_target_group" "dictionary-tg" {
  name = "${var.project}-dictionary-tg"
  port = var.dictionary-tg-port
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"

  health_check {
    enabled = true
    path = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
  deregistration_delay = 30
  
  tags = {
    name = "${var.project}-dictionary-tg"
  }
}

resource "aws_lb_listener" "text-processing-listner" {
 load_balancer_arn = aws_lb.main_alb.arn
 port = 80
 protocol = "HTTP"
 default_action {
   type = "forward"
   target_group_arn = aws_lb_target_group.text-processing-tg.arn
 }
}

resource "aws_lb_listener_rule" "text_process" {
  listener_arn = aws_lb_listener.text-processing-listner.arn
  
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.text-processing-tg.arn
  }

  condition {
    path_pattern {
      values = ["/process/*"]
    }
  }
}

resource "aws_lb_listener_rule" "dictionary" {
  listener_arn = aws_lb_listener.text-processing-listner.arn
  
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.dictionary-tg.arn
  }

  condition {
    path_pattern {
      values = ["/dictionary/*"]
    }
  }
}