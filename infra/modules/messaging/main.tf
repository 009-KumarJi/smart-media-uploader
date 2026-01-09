resource "aws_sqs_queue" "dlq" {
  name = "smmu-${var.env}-jobs-dlq"
}

resource "aws_sqs_queue" "jobs" {
  name = "smmu-${var.env}-jobs-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

output "jobs_queue_url" {
  value = aws_sqs_queue.jobs.url
}
