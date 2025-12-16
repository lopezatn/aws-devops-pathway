resource "aws_cloudwatch_dashboard" "sysdev" {
  dashboard_name = "sysdev-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0, y = 0, width = 12, height = 6,
        properties = {
          title  = "Traffic (RequestCount)"
          region = "eu-north-1"
          metrics = [
            [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.sysdev_alb.arn_suffix ]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type = "metric",
        x = 12, y = 0, width = 12, height = 6,
        properties = {
          title  = "Errors (ALB 5XX vs Target 5XX)"
          region = "eu-north-1"
          metrics = [
            [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", aws_lb.sysdev_alb.arn_suffix, { "stat": "Sum" } ],
            [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.sysdev_alb.arn_suffix, "TargetGroup", aws_lb_target_group.sysdev_tg.arn_suffix, { "stat": "Sum" } ]
          ]
          period = 60
        }
      },
      {
        type = "metric",
        x = 0, y = 6, width = 12, height = 6,
        properties = {
          title  = "Latency (TargetResponseTime)"
          region = "eu-north-1"
          metrics = [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.sysdev_alb.arn_suffix, "TargetGroup", aws_lb_target_group.sysdev_tg.arn_suffix ]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type = "metric",
        x = 12, y = 6, width = 12, height = 6,
        properties = {
          title  = "Capacity signals (Healthy hosts, ASG InService)"
          region = "eu-north-1"
          metrics = [
            [ "AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.sysdev_alb.arn_suffix, "TargetGroup", aws_lb_target_group.sysdev_tg.arn_suffix, { "stat": "Minimum" } ],
            [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", aws_autoscaling_group.sysdev_asg.name, { "stat": "Minimum" } ]
          ]
          period = 60
        }
      }
    ]
  })
}
