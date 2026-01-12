resource "aws_iam_role" "ecs_worker" {
  name = "smmu-${var.env}-ecs-worker"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_worker_policy" {
  role = aws_iam_role.ecs_worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Read raw media
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::smmu-${var.env}-raw-media",
          "arn:aws:s3:::smmu-${var.env}-raw-media/*"
        ]
      },

      # Write processed media
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::smmu-${var.env}-processed-media/*"
        ]
      },

      # Update DynamoDB
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/smmu-${var.env}-jobs"
      },

      # Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_worker_execution" {
  role       = aws_iam_role.ecs_worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "transcode" {
  family                   = "smmu-${var.env}-transcode"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_worker.arn
  task_role_arn            = aws_iam_role.ecs_worker.arn

  container_definitions = jsonencode([
    {
      name      = "transcode"
      image     = aws_ecr_repository.transcode.repository_url
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/smmu-${var.env}-transcode"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "transcribe" {
  family                   = "smmu-${var.env}-transcribe"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_worker.arn
  task_role_arn            = aws_iam_role.ecs_worker.arn

  container_definitions = jsonencode([
    {
      name      = "transcribe"
      image     = aws_ecr_repository.transcribe.repository_url
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/smmu-${var.env}-transcribe"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
