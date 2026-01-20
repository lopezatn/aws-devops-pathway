resource "aws_autoscaling_policy" "tt_req_per_target" {
  name                   = "webhost-tt-req-per-target"
  autoscaling_group_name = aws_autoscaling_group.webhost_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.webhost_alb.arn_suffix}/${aws_lb_target_group.webhost_tg.arn_suffix}"
    }

    target_value = 1000
  }
}
