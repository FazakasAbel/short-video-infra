resource "aws_instance" "ec2-bastion-host" {
    ami = "ami-04cdc91e49cb06165"
    instance_type = "t3.micro"
    key_name = var.key_name
    vpc_security_group_ids = [ var.ec2-bastion-sg_id ]
    subnet_id = var.public_subnet_1a_id
    associate_public_ip_address = true
    root_block_device {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
      encrypted = true
      tags = {
        Name = "${var.project_name}-ec2-bastion-host-root-volume-dev"
      }
    }
    credit_specification {
      cpu_credits = "standard"
    }
    tags = {
        Name = "${var.project_name}-ec2-bastion-host-dev"
    }
}