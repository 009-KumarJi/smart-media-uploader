output "transcode_repo_url" {
  value = aws_ecr_repository.transcode.repository_url
}

output "transcribe_repo_url" {
  value = aws_ecr_repository.transcribe.repository_url
}
