resource "aws_lambda_function" "dispatcher" {
  function_name = "smmu-${var.env}-dispatcher"
  role          = aws_iam_role.dispatcher.arn
  handler       = "handler.handler"
  runtime       = "python3.11"
  timeout       = 30

  filename         = "${path.module}/dispatcher.zip"
  source_code_hash = filebase64sha256("${path.module}/dispatcher.zip")

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.pipeline.arn
      JOBS_TABLE       = "smmu-${var.env}-jobs"
    }
  }
}
