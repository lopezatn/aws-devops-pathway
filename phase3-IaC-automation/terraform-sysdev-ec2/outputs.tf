output "security_group_id" {
  value = aws_security_group.web_sg.id
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.default_vpc_subnets.ids
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.webhost_alb.dns_name
}