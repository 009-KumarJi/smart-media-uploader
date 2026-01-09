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
