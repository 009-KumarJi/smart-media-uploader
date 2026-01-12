variable "env" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "jobs_queue_arn" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "transcode_task_arn" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}