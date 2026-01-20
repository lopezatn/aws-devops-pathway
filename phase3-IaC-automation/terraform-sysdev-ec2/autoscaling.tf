resource "aws_autoscaling_group" "webhost_asg" {
  name             = "webhost-asg"
  max_size         = var.max_size
  min_size         = var.min_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.webhost_lt.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.webhost_tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 60
    }
  }

  tag {
    key                 = "Name"
    value               = "webhost-server"
    propagate_at_launch = true
  }

}
