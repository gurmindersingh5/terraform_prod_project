################################################################################
# ASG MODULE
# Date: April 14th, 2024. 
# auto scaling group for 2 flask app instances attached with ALB
################################################################################

resource "random_string" "random_prefix" {
  length  = 4
  special = false
  upper   = false
  numeric  = true
}

########################################################
# Launch template for ASG
########################################################

resource "aws_launch_template" "flask-app-template" {
  name = "${random_string.random_prefix.result}-flask-app-template"
  image_id = "ami-05d4121edd74a9f06"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  # network_interfaces {
  #   associate_public_ip_address = false
  # }

  user_data = filebase64("${path.module}/user-data-ec2.sh")

  # security group association
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

}


########################################################
# target group
########################################################

resource "aws_lb_target_group" "tg" {
  name     = "albtg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id 
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "albtg"
  }
}

########################################################
# Autoscaling group
########################################################

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-01"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  
  launch_template {
    id = aws_launch_template.flask-app-template.id
  }     

  vpc_zone_identifier       = [var.private_subnet_id1, var.private_subnet_id2]

  target_group_arns    = [aws_lb_target_group.tg.arn]

}

########################################################
# security group
########################################################

resource "aws_security_group" "ec2-sg" {
  name        = "allow_alb_traffic"
  description = "Allow alb inbound traffic"
  vpc_id      = var.vpc_id  

  ingress {
    description = "Allow port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}





