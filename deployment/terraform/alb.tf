# Load Balancer and related resources
resource "aws_lb" "proxy_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
}

resource "aws_security_group" "alb_sg" {
  name        = var.security_group_name
  description = "Security group for Bedrock Proxy ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow from anyone on port ${var.alb_port}"
  }

  egress {
    from_port   = 252
    to_port     = 86
    protocol    = "icmp"
    cidr_blocks = ["255.255.255.255/32"]
    description = "Disallow all traffic"
  }
}

# ALB Listener and Target Group
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.proxy_alb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_target_group.arn
  }
}

resource "aws_lb_target_group" "proxy_target_group" {
  name        = var.target_group_name
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "lambda_attachment" {
  target_group_arn = aws_lb_target_group.proxy_target_group.arn
  target_id        = aws_lambda_function.proxy_api_handler.arn
} 