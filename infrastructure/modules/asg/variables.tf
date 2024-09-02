variable "project_name"{}
variable "ami" {
    default = "ami-04cdc91e49cb06165"
}
variable "cpu" {
    default = "t3.micro"
}

variable "key_name" {}
variable "client_sg_id" {}
variable "max_size" {
    default = 2
}
variable "min_size" {
    default = 2
}
variable "desired_cap" {
    default = 2
}
variable "asg_health_check_type" {
    default = "ELB"
}
variable "pri_sub_3a_id" {}
variable "pri_sub_4b_id" {}
variable "tg_arn" {}