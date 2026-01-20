resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "sysdev-asg-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  statistic           = "Average"
  threshold           = 80

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webhost_asg.name
  }

  alarm_actions = [aws_sns_topic.webhost_alerts.arn]
}