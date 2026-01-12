variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS and ALB"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets for ALB"
  type        = list(string)
}

variable "queue_url" {
  description = "SQS jobs queue URL"
  type        = string
}

variable "aws_region" {
  type = string
}