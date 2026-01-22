variable "instance_type" {
  description = "EC2 instance type for the web ASG"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "webhost"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the ALB"
  type        = string
}