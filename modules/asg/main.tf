locals {
  http_port = 80 
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
  ssh_port = 22
}

resource "aws_security_group" "sg_alb" {
  name        = "${var.env}-sg-alb"
  description = "Allow HTTP protocol from internet to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from external source"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
  tags = {
    "Name" = "Allow HTTP to ALB"
  }
}
resource "aws_security_group" "sg_ssh" {
  name        = "${var.env}-sg-ssh"
  description = "Allow ssh protocol from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from external source"
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = "tcp"
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.all_ips
  }
  tags = {
    "Name" = "Allow SSH to SG"
  }
}
resource "aws_security_group" "sg_web" {
  name        = "${var.env}-sg-web"
  description = "Allow HTTP protocol from ALB to our Web Target Group"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Allow HTTP from ALB to Web"
    from_port       = local.http_port
    to_port         = local.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  egress {
    description = "Allow all to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.all_ips
  }

  tags = {
    "Name" = "Allow HTTP from ALB to Target Group"
  }
}

resource "aws_launch_template" "web_lt" {
  name_prefix = "${var.env}-web-app-lt-"
  block_device_mappings {
    device_name = "/dev/sdk"
    ebs {
      volume_size = 10
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_web.id, aws_security_group.sg_ssh.id]
  image_id               = var.image_id
  key_name = var.key_name
  tag_specifications {
    resource_type = "instance"

    tags = {
      "Name" = "Web"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "web_tg" {
  name     = "${var.env}-web-tg"
  port     = local.http_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    healthy_threshold   = 2
    path                = "/"
    port                = local.http_port
    protocol            = "HTTP"
    timeout             = 8
    interval            = 10
    unhealthy_threshold = 5
  }
}

resource "aws_lb" "web_alb" {
  name               = "${var.env}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [for subnet_id in var.vpc_subnet_id : subnet_id]

  tags = {
    "Environment" = "${var.env}"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "${local.http_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web_tg.arn
  }
}

resource "aws_alb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web_tg.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                      = "${aws_launch_template.web_lt.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [for subnet_id in var.vpc_subnet_id : subnet_id]
  target_group_arns   = toset([aws_alb_target_group.web_tg.arn])

  tag {
    key                 = "Name"
    value               = "Web Application Auto Scaling Group"
    propagate_at_launch = true
  }
  # provisioner "local-exec" {
  #   command = "./get_ips.sh"
  # }
  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_autoscaling_policy" "target_tracking" {
  name = "target_tracking"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 200
  target_tracking_configuration {
      predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
  }
  target_value = 40
  }

}