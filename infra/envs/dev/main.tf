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
}

module "orchestration" {
  source = "../../modules/orchestration"
  env    = var.env
}
