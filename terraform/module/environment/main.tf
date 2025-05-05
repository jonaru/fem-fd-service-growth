module "network" {
  source = "../network"

  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  bastion_ingress    = var.bastion_ingress
  cidr               = "10.0.0.0/16"
  name               = var.name
}

module "database" {
  source = "../database"

  name     = var.name
  vpc_name = module.network.vpc_name
}

module "cluster" {
  source = "../cluster"

  name     = var.name
  vpc_name = module.network.vpc_name

  capacity_providers = {
    "spot" = {
      instance_type = "t3a.medium"
      market_type   = "spot"
    }
  }
}

module "service-example" {
  source = "../service"

  capacity_provider = "spot"
  cluster_name      = var.name
  listener_arn      = module.cluster.listener_arn
  name              = "example"
  paths             = ["/*"]
  vpc_name          = module.network.vpc_name
}
