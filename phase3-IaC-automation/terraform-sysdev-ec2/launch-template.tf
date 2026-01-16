resource "aws_launch_template" "webhost_lt" {
  name_prefix   = "webhost-"
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type
  key_name      = "webhost-nginx-key"

  iam_instance_profile {
    name = "webhost-ec2-instance-profile"
  }

  vpc_security_group_ids = [
    aws_security_group.webhost_sg.id,
  ]

  user_data = base64encode(file("${path.module}/userdata-script.sh"))
}
