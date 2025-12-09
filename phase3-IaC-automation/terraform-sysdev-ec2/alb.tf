# Application Load Balancer
resource "aws_lb" "sysdev_alb" {
  name               = "sysdev-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]

  subnets = [
    "subnet-0a3ab44f6771e1f6d", # eu-north-1a
    "subnet-0f6a4dc24d6c81f3a", # eu-north-1c
    "subnet-03971a428f793d2e7", # eu-north-1b
  ]
}

# Target Group for the ASG instances
resource "aws_lb_target_group" "sysdev_tg" {
  name     = "sysdev-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0b18e9d3e37be5edc"
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener: ALB listens on port 80 and forwards to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.sysdev_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sysdev_tg.arn
  }
}
