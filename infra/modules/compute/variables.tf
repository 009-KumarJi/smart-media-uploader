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
