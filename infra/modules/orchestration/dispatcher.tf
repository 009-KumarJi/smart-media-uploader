resource "aws_iam_role" "dispatcher" {
  name = "smmu-${var.env}-dispatcher"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "dispatcher_policy" {
  role = aws_iam_role.dispatcher.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ########################################
      # STEP FUNCTIONS (start pipelines)
      ########################################
      {
        Effect = "Allow"
        Action = ["states:StartExecution"]
        Resource = "arn:aws:states:ap-south-1:${data.aws_caller_identity.current.account_id}:stateMachine:smmu-${var.env}-pipeline"
      },

      ########################################
      # JOBS TABLE (core system of record)
      ########################################
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:ap-south-1:${data.aws_caller_identity.current.account_id}:table/smmu-${var.env}-jobs"
      },

      ########################################
      # JOBS STREAM (realtime trigger)
      ########################################
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Resource = var.jobs_stream_arn
      },

      ########################################
      # WEBSOCKET CONNECTION TABLE
      ########################################
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:ap-south-1:${data.aws_caller_identity.current.account_id}:table/smmu-${var.env}-ws-connections"
      },

      ########################################
      # SQS (job dispatch)
      ########################################
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.jobs_queue_arn
      },

      ########################################
      # WEBSOCKET PUSH (this was missing)
      ########################################
      {
        Effect = "Allow"
        Action = "execute-api:ManageConnections"
        Resource = "arn:aws:execute-api:ap-south-1:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.ws.id}/*"
      },

      ########################################
      # LOGGING
      ########################################
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

