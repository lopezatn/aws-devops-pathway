resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/sysdev/nginx"
  retention_in_days = 7
}
