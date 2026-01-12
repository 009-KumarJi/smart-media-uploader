output "transcode_repo_url" {
  value = aws_ecr_repository.transcode.repository_url
}

output "transcribe_repo_url" {
  value = aws_ecr_repository.transcribe.repository_url
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "transcode_task_arn" {
  value = aws_ecs_task_definition.transcode.arn
}