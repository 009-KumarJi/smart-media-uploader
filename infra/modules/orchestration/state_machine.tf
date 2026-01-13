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
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"

        Parameters = {
          Cluster        = var.ecs_cluster_arn
          LaunchType     = "FARGATE"
          TaskDefinition = var.transcode_task_arn

          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = var.public_subnets
              AssignPublicIp = "ENABLED"
            }
          }

          Overrides = {
            ContainerOverrides = [
              {
                Name = "transcode"
                Environment = [
                  {
                    Name = "JOB_ID"
                    "Value.$" = "$.jobId"
                  },
                  {
                    Name = "INPUT_KEY"
                    "Value.$" = "$.inputKey"
                  },
                  {
                    Name  = "OUTPUT_KEY"
                    Value = "s3://smmu-${var.env}-processed-media/output.mp4"
                  },
                  {
                    Name  = "JOBS_TABLE"
                    Value = "smmu-${var.env}-jobs"
                  },
                  { 
                    Name: "USER_ID", 
                    "Value.$": "$.userId" 
                  },
                  {
                    "Name": "RAW_BUCKET",
                    "Value": "smmu-${var.env}-raw-media"
                  },
                  {
                    "Name": "PROCESSED_BUCKET",
                    "Value": "smmu-${var.env}-processed-media"
                  }
                ]
              }
            ]
          }
        }

        ResultPath = "$.ecs" 

        Next = "MarkCompleted"
      }

      VideoPipeline = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"

        Parameters = {
          Cluster        = var.ecs_cluster_arn
          LaunchType     = "FARGATE"
          TaskDefinition = var.transcode_task_arn

          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = var.public_subnets
              AssignPublicIp = "ENABLED"
            }
          }

          Overrides = {
            ContainerOverrides = [
              {
                Name = "transcode"
                Environment = [
                  { Name = "JOB_ID",    "Value.$" = "$.jobId" },
                  { Name = "INPUT_KEY","Value.$" = "$.inputKey" },
                  { Name = "USER_ID",  "Value.$" = "$.userId" },
                  { Name = "RAW_BUCKET",       Value = "smmu-${var.env}-raw-media" },
                  { Name = "PROCESSED_BUCKET", Value = "smmu-${var.env}-processed-media" },
                  { Name = "JOBS_TABLE",       Value = "smmu-${var.env}-jobs" }
                ]
              }
            ]
          }
        }

        ResultPath = "$.ecs"
        Next = "MarkCompleted"
      }


      AudioPipeline = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"

        Parameters = {
          Cluster        = "arn:aws:ecs:ap-south-1:${data.aws_caller_identity.current.account_id}:cluster/smmu-${var.env}-cluster"
          LaunchType     = "FARGATE"
          TaskDefinition = "arn:aws:ecs:ap-south-1:${data.aws_caller_identity.current.account_id}:task-definition/smmu-${var.env}-transcribe"

          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = var.public_subnets
              AssignPublicIp = "ENABLED"
            }
          }

          Overrides = {
            ContainerOverrides = [
              {
                Name = "transcribe"
                Environment = [
                  { 
                    Name = "JOB_ID" 
                    "Value.$" = "$.jobId" 
                  },
                  { 
                    Name = "INPUT_KEY" 
                    "Value.$" = "$.inputKey" 
                  },
                  { 
                    Name = "OUTPUT_KEY"
                    "Value.$" = "States.Format('s3://smmu-${var.env}-processed-media/transcripts/{}.txt', $.jobId)" 
                  },
                  { 
                    Name = "JOBS_TABLE"
                    Value    = "smmu-${var.env}-jobs" 
                  },
                  { 
                    Name: "USER_ID", 
                    "Value.$": "$.userId" 
                  }
                ]
              }
            ]
          }
        }

        ResultPath = "$.ecs"
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
