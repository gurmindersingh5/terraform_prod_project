################################################################################
# ALB MODULE
# Date: April 14th, 2024. 
# ALB targeting to ASG
################################################################################

################################################################################
# load balancer
################################################################################

resource "aws_lb" "alb-for-autoscaling-group" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [var.public_subnet_id1, var.public_subnet_id2]
  
  # set to true in production but flase for testing
  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "flask-lb-s3"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}


################################################################################
# listener for alb
################################################################################

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb-for-autoscaling-group.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.alb_tg
  }
}

################################################################################
# security group
################################################################################

resource "aws_security_group" "lb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB to allow HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ALB Security Group"
    Environment = "Production"
  }
}
