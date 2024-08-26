variable "project_name" {}
variable "vpc_id" {}
variable "public_subnet_1a_id" {}
# EC2 Bastion Host variables
variable "ec2-bastion-ingress-ip-1" {
  type = string
}
variable "key_name" {}
variable "ec2-bastion-sg_id" {}