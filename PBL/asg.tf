  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier  = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]
  target_group_arns    = [aws_lb_target_group.my-target-group.arn]
  health_check_type    = "EC2"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}