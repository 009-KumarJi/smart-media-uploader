resource "aws_lambda_event_source_mapping" "jobs_queue_trigger" {
  event_source_arn = var.jobs_queue_arn
  function_name   = aws_lambda_function.dispatcher.arn
  batch_size      = 1
}
