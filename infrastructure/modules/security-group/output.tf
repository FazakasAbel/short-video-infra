
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "client_sg_id" {
  value = aws_security_group.client_sg.id
}

output "bastion_host_sg_id" {
  value = aws_security_group.ec2-bastion-sg.id
}