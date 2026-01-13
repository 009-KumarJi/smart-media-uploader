locals {
  ws_lambdas = {
    "ws-connect"    = "ws-connect.zip"
    "ws-disconnect" = "ws-disconnect.zip"
    "ws-subscribe"  = "ws-subscribe.zip"
  }
}

resource "aws_lambda_function" "ws" {
  for_each = local.ws_lambdas

  function_name = "smmu-${var.env}-${each.key}"
  role          = aws_iam_role.dispatcher.arn
  runtime       = "python3.11"
  handler       = "handler.handler"
  timeout       = 30

  filename         = "${path.module}/${each.value}"
  source_code_hash = filebase64sha256("${path.module}/${each.value}")

  environment {
    variables = {
      WS_TABLE = "smmu-${var.env}-ws-connections"
    }
  }
}
