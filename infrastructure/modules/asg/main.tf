resource "aws_instance" "control-plane" {
    ami = "ami-04cdc91e49cb06165"
    instance_type = "t3.small"
    key_name = var.key_name
    vpc_security_group_ids = [ var.client_sg_id ]
    subnet_id = var.pri_sub_3a_id
    associate_public_ip_address = false
    root_block_device {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
      encrypted = true
      tags = {
        Name = "control-plane"
      }
    }
    credit_specification {
      cpu_credits = "standard"
    }
    tags = {
        Name = "control-plane"
    }
}

resource "aws_instance" "worker" {
    ami = "ami-04cdc91e49cb06165"
    instance_type = "t3.small"
    key_name = var.key_name
    vpc_security_group_ids = [ var.client_sg_id ]
    subnet_id = var.pri_sub_3a_id
    associate_public_ip_address = false
    root_block_device {
      volume_size = 12
      delete_on_termination = true
      volume_type = "gp2"
      encrypted = true
      tags = {
        Name = "worker"
      }
    }
    credit_specification {
      cpu_credits = "standard"
    }
    tags = {
        Name = "worker"
    }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
    target_group_arn = var.tg_arn
    target_id        = aws_instance.control-plane.id
}