resource "aws_sfn_state_machine" "pipeline" {
  name     = "smmu-${var.env}-pipeline"
  role_arn = aws_iam_role.step_fn.arn

  definition = jsonencode({
    StartAt = "ValidateInput"
    States = {

      ValidateInput = {
        Type = "Task"
        Resource = "arn:aws:lambda:ap-south-1:${data.aws_caller_identity.current.account_id}:function:smmu-${var.env}-validate-input"
        Next = "DetectType"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next = "FailJob"
        }]
      }

      DetectType = {
        Type = "Task"
        Resource = "arn:aws:lambda:ap-south-1:${data.aws_caller_identity.current.account_id}:function:smmu-${var.env}-detect-type"
        Next = "BranchByType"
      }

      BranchByType = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.type"
            StringEquals = "image"
            Next = "ImagePipeline"
          },
          {
            Variable = "$.type"
            StringEquals = "video"
            Next = "VideoPipeline"
          },
          {
            Variable = "$.type"
            StringEquals = "audio"
            Next = "AudioPipeline"
          }
        ]
        Default = "FailJob"
      }

      ImagePipeline = {
        Type = "Pass"
        Result = { "message": "image pipeline placeholder" }
        Next = "MarkCompleted"
      }

      VideoPipeline = {
        Type = "Pass"
        Result = { "message": "video pipeline placeholder" }
        Next = "MarkCompleted"
      }

      AudioPipeline = {
        Type = "Pass"
        Result = { "message": "audio pipeline placeholder" }
        Next = "MarkCompleted"
      }

      MarkCompleted = {
        Type = "Task"
        Resource = "arn:aws:lambda:ap-south-1:${data.aws_caller_identity.current.account_id}:function:smmu-${var.env}-update-status"
        End = true
      }

      FailJob = {
        Type = "Task"
        Resource = "arn:aws:lambda:ap-south-1:${data.aws_caller_identity.current.account_id}:function:smmu-${var.env}-update-status"
        End = true
      }
    }
  })
}
