module "vpc" {
  source = "../modules/vpc"
    region = var.region
    project_name = var.project_name
    vpc_cidr         = var.vpc_cidr
    pub_sub_1a_cidr = var.pub_sub_1a_cidr
    pub_sub_2b_cidr = var.pub_sub_2b_cidr
    pri_sub_3a_cidr = var.pri_sub_3a_cidr
    pri_sub_4b_cidr = var.pri_sub_4b_cidr
}

module "nat" {
  source = "../modules/nat"

  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  igw_id        = module.vpc.igw_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  vpc_id        = module.vpc.vpc_id
  pri_sub_3a_id = module.vpc.pri_sub_3a_id
  pri_sub_4b_id = module.vpc.pri_sub_4b_id
}

module "security-group" {
  source = "../modules/security-group"

  vpc_id = module.vpc.vpc_id
  ec2-bastion-ingress-ip-1 = var.ec2-bastion-ingress-ip-1
}

# creating Key for instances
module "key" {
  source = "../modules/key"

  public-key-path = var.public-key-path
  private-key-path = var.private-key-path

}

# Creating Application Load balancer
module "alb" {
  source         = "../modules/alb"
  project_name   = module.vpc.project_name
  alb_sg_id      = module.security-group.alb_sg_id
  pub_sub_1a_id  = module.vpc.pub_sub_1a_id
  pub_sub_2b_id  = module.vpc.pub_sub_2b_id
  vpc_id         = module.vpc.vpc_id
}

module "asg" {
  source         = "../modules/asg"
  project_name   = module.vpc.project_name
  key_name       = module.key.key_name
  client_sg_id   = module.security-group.client_sg_id
  pri_sub_3a_id  = module.vpc.pri_sub_3a_id
  pri_sub_4b_id  = module.vpc.pri_sub_4b_id
  tg_arn         = module.alb.tg_arn
  cpu            = var.cpu

}

module "bastion" {
  source                   = "../modules/bastion"
  
  project_name             = var.project_name
  ec2-bastion-ingress-ip-1 = var.ec2-bastion-ingress-ip-1
  ec2-bastion-sg_id        = module.security-group.bastion_host_sg_id
  vpc_id                   = module.vpc.vpc_id
  public_subnet_1a_id      = module.vpc.pub_sub_1a_id
  key_name                 = module.key.key_name
}

module "efs" {
  source           = "../modules/efs"

  lifecycle_policy = var.lifecycle_policy
}