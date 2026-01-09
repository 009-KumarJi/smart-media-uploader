resource "aws_iam_role" "step_fn" {
  name = "smmu-${var.env}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_fn_policy" {
  role = aws_iam_role.step_fn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "ecs:RunTask",
          "ecs:StopTask",
          "dynamodb:UpdateItem",
          "sqs:SendMessage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "pipeline" {
  name     = "smmu-${var.env}-pipeline"
  role_arn = aws_iam_role.step_fn.arn

  definition = jsonencode({
    StartAt = "Placeholder",
    States = {
      Placeholder = {
        Type = "Pass",
        End  = true
      }
    }
  })
}
