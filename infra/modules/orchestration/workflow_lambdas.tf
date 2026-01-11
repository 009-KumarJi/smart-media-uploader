locals {
  lambdas = ["validate-input", "detect-type", "update-status"]
}

resource "aws_lambda_function" "workflow" {
  for_each = toset(local.lambdas)

  function_name = "smmu-${var.env}-${each.key}"
  role          = aws_iam_role.dispatcher.arn
  runtime       = "python3.11"
  handler       = "handler.handler"
  timeout       = 30

  filename         = "${path.module}/${each.key}.zip"
  source_code_hash = filebase64sha256("${path.module}/${each.key}.zip")

  environment {
    variables = {
      JOBS_TABLE = "smmu-${var.env}-jobs"
    }
  }
}
