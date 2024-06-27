data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "my_labtop" {
  key_name   = "my_labtop"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_launch_configuration" "asg-config" {
  name_prefix     = "asg-config"
  image_id        = data.aws_ami.latest_ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my_labtop.key_name
  security_groups = [aws_security_group.asg_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg"
  vpc_zone_identifier       = [aws_subnet.public-1.id, aws_subnet.public-2.id]
  launch_configuration      = aws_launch_configuration.asg-config.name
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 200
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.elb.name]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ASG EC2 instance"
    propagate_at_launch = true
  }
}

# resource "aws_autoscaling_policy" "asg-cpu-policy" {
#   name                   = "asg-cpu-policy"
#   autoscaling_group_name = aws_autoscaling_group.asg.name
#   adjustment_type        = "ChangeInCapacity"
#   scaling_adjustment     = "1"
#   cooldown               = "200"
#   policy_type            = "SimpleScaling"
# }

# resource "aws_cloudwatch_metric_alarm" "asg-cpu-alarm" {
#   alarm_name          = "asg-cpu-alarm"
#   alarm_description   = "Alarm once CPU Uses Increase"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "30"

#   dimensions = {
#     "AutoScalingGroupName" = aws_autoscaling_group.asg.name
#   }

#   actions_enabled = true
#   alarm_actions   = [aws_autoscaling_policy.asg-cpu-policy.arn]
# }

# resource "aws_autoscaling_policy" "asg-cpu-policy-scaledown" {
#   name                   = "asg-cpu-policy-scaledown"
#   autoscaling_group_name = aws_autoscaling_group.asg.name
#   adjustment_type        = "ChangeInCapacity"
#   scaling_adjustment     = "-1"
#   cooldown               = "200"
#   policy_type            = "SimpleScaling"
# }

# resource "aws_cloudwatch_metric_alarm" "asg-cpu-alarm-scaledown" {
#   alarm_name          = "asg-cpu-alarm-scaledown"
#   alarm_description   = "Alarm once CPU Uses Decrease"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "10"

#   dimensions = {
#     "AutoScalingGroupName" = aws_autoscaling_group.asg.name
#   }

#   actions_enabled = true
#   alarm_actions   = [aws_autoscaling_policy.asg-cpu-policy-scaledown.arn]
# }