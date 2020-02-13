provider "aws" {
  region = "eu-central-1"
}

module "app_vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 2.24.0"
  name               = "app-vpc"
  cidr               = "10.30.0.0/16"
  azs                = ["eu-central-1a", "eu-central-1b"]
  private_subnets    = ["10.30.1.0/24", "10.30.2.0/24"]
  public_subnets     = ["10.30.101.0/24"]
  enable_ipv6        = false
  enable_nat_gateway = false
  single_nat_gateway = false
  public_subnet_tags = {
    name = "public"
  }

  tags = {
    Environment = "Test"
  }

}

module "app_nat_instance" {
  source              = "../"
  env_name            = "Test"
  key_pair            = "test-key"
  vpc_id              = module.app_vpc.vpc_id
  vpc_cidr            = module.app_vpc.vpc_cidr_block
  vpc_public_subnet   = module.app_vpc.public_subnets[0]
  vpc_private_subnets = module.app_vpc.private_subnets
  vpc_private_routes  = module.app_vpc.private_route_table_ids
  bastion_subnet_cidr = "10.20.0.0/16"
}