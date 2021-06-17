terraform {
  required_version = ">= 0.14.3"
}

provider "aws" {
  region = "eu-north-1"
}

module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  private_sn_count = 3
  public_sn_count  = 2
  max_subnets      = 20
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]

}

module "instances" {
  source           = "./instances"
  public_sg        = module.networking.public_sg
  public_subnets   = module.networking.public_subnets
  controller_count = 1
  worker_count     = 2
  cluster_name     = "k0s"
  cluster_flavor   = "t3.micro"
  user_data_path   = "${path.root}/user-data.tpl"
}
