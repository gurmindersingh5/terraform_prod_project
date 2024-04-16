############################
# main for pub-private-subnet-deployment-prod
############################

provider "aws" {
    region = var.region
}

module "vpc" {
  source = "./modules/vpc"

}

module "asg" {
  source = "./modules/asg"
  private_subnet_id1 = module.vpc.private_subnet_id1
  private_subnet_id2 = module.vpc.private_subnet_id2
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_id2 = module.vpc.public_subnet_id2
  public_subnet_id1 = module.vpc.public_subnet_id1
  alb_tg = module.asg.alb_tg

}

