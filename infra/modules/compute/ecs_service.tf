# 1. Security Group for ECS Tasks (Only allows traffic from ALB)
resource "aws_security_group" "ecs_tasks" {
  name   = "smmu-${var.env}-ecs-tasks-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Only accept ALB traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. The Cluster (A logical group)
resource "aws_ecs_cluster" "this" {
  name = "smmu-${var.env}-cluster"
}

# 3. The Service (Runs the containers)
resource "aws_ecs_service" "api" {
  name            = "smmu-${var.env}-api"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}