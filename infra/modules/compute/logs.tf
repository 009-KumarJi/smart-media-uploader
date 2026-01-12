resource "aws_cloudwatch_log_group" "transcode" {
  name              = "/ecs/smmu-${var.env}-transcode"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "transcribe" {
  name              = "/ecs/smmu-${var.env}-transcribe"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/smmu-${var.env}-api"
  retention_in_days = 7
}
