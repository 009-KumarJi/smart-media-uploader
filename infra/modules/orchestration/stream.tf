resource "aws_lambda_event_source_mapping" "job_stream" {
  event_source_arn = var.jobs_stream_arn
  function_name    = aws_lambda_function.job_stream_broadcaster.arn
  starting_position = "LATEST"
}

resource "aws_lambda_function" "job_stream_broadcaster" {
  function_name = "smmu-${var.env}-job-stream-broadcaster"
  role          = aws_iam_role.dispatcher.arn
  runtime       = "python3.11"
  handler       = "handler.handler"
  timeout       = 30

  filename         = "${path.module}/job-stream-broadcaster.zip"
  source_code_hash = filebase64sha256("${path.module}/job-stream-broadcaster.zip")

  environment {
    variables = {
      WS_TABLE   = "smmu-${var.env}-ws-connections"
      WS_ENDPOINT = aws_apigatewayv2_api.ws.api_endpoint
    }
  }
}
