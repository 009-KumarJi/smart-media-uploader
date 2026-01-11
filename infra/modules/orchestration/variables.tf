variable "env" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}
variable "jobs_queue_arn" {
  type = string
}