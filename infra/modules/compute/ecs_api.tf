resource "aws_ecs_task_definition" "api" {
  family                   = "smmu-${var.env}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.api.arn

  container_definitions = jsonencode([
    {
      name  = "api"
      image = aws_ecr_repository.api.repository_url
      portMappings = [
        { containerPort = 80 }
      ]
      environment = [
        { name = "RAW_BUCKET", value = "smmu-${var.env}-raw-media" },
        { name = "JOBS_TABLE", value = "smmu-${var.env}-jobs" },
        { name = "QUEUE_URL",  value = var.queue_url }
      ]
    }
  ])
}
