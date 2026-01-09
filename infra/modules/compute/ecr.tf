resource "aws_ecr_repository" "api" {
  name = "smmu-${var.env}-api"
}
