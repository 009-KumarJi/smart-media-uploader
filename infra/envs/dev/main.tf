module "networking" {
  source = "../../modules/networking"
  env    = var.env
}

module "storage" {
  source = "../../modules/storage"
  env    = var.env
}

module "data" {
  source = "../../modules/data"
  env    = var.env
}

module "messaging" {
  source = "../../modules/messaging"
  env    = var.env
}

module "compute" {
  source         = "../../modules/compute"
  env            = var.env
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  queue_url      = module.messaging.jobs_queue_url
  aws_region     = var.aws_region
  # expose worker repos
  # nothing to pass in yet, just outputs
}

module "orchestration" {
  source          = "../../modules/orchestration"
  env             = var.env
  jobs_queue_arn  = module.messaging.jobs_queue_arn
  jobs_stream_arn = module.data.jobs_stream_arn

  ecs_cluster_arn     = module.compute.ecs_cluster_arn
  transcode_task_arn  = module.compute.transcode_task_arn
  public_subnets      = module.networking.public_subnets
}