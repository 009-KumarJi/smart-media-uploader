resource "aws_ecr_repository" "api" {
  name = "smmu-${var.env}-api"
}

resource "aws_ecr_repository" "transcode" {
  name = "smmu-${var.env}-transcode-worker"
}

resource "aws_ecr_repository" "transcribe" {
  name = "smmu-${var.env}-transcribe-worker"
}
