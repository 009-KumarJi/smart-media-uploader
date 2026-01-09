# 1. Security Group for ALB (Allows Internet Access)
resource "aws_security_group" "alb" {
  name   = "smmu-${var.env}-alb-sg"
  vpc_id = var.vpc_id

  # Allow anyone on earth to call port 80 (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALB to talk to anything outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. The Actual Load Balancer
resource "aws_lb" "api" {
  name               = "smmu-${var.env}-api-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

# 3. The Target Group (Where requests get sent)
resource "aws_lb_target_group" "api" {
  name        = "smmu-${var.env}-api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/docs" # Checking if API is alive
  }
}

# 4. The Listener (Forwards Traffic)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# Output the URL so we can click it later
output "alb_dns_name" {
  value = aws_lb.api.dns_name
}