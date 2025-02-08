variable "sg" {
  type = string
}

variable "subnet_id_list" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}


resource "aws_lb" "create_lb" {
  name               = "gal2-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg]
  subnets            = var.subnet_id_list
  enable_deletion_protection = false

  tags = {
    Name = "gal-lb"
  }
}

resource "aws_lb_target_group" "create_target_group" {
  name     = "gal-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval = 30
    path     = "/"
    protocol = "HTTP"
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "gal-target-group"
  }
}

resource "aws_launch_template" "gal_launch_template" {
  name          = "gal-launch-template"
  image_id      = "ami-0e1bed4f06a3b463d"
  instance_type = "t2.micro"

  network_interfaces {
    security_groups = [var.sg]
  }
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 1
  min_size             = 1
  max_size             = 3
  vpc_zone_identifier  = var.subnet_id_list
  target_group_arns    = [aws_lb_target_group.create_target_group.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout = "0"

  launch_template {
    id      = aws_launch_template.gal_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Gal-AutoScalingInstance"
    propagate_at_launch = true
  }
}

# Output ALB DNS Name
output "alb_dns_name" {
  value = aws_lb.create_lb.dns_name
}
