# main.tf

provider "aws" {
  region = "eu-north-1"
}

# Create the VPC

resource "aws_vpc" "main_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

# Create the public subnets

resource "aws_subnet" "pb_subnet_1a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "pb-subnet-1a"
  }
}

resource "aws_subnet" "pb_subnet_1b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "pb-subnet-1b"
  }
}

# Create the Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_igw"
  }
}

# Create the Route Table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "public_rt"
  }
}

# Create the routes

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "local_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "192.168.0.0/16"
  gateway_id             = local
}

# Associate the subnets with the route table

resource "aws_route_table_association" "subnet_1a_assoc" {
  subnet_id      = aws_subnet.pb_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_1b_assoc" {
  subnet_id      = aws_subnet.pb_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

# Create the Security Group for the Bastion Host
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

# Create the Bastion Host
resource "aws_instance" "bastion_host" {
  ami           = "ami-04cdc91e49cb06165" # Replace with a suitable AMI for your region
  instance_type = "t3.micro" # Choose the instance type based on your needs
  subnet_id     = aws_subnet.pb_subnet_1a.id
  key_name       = "short-video" # Ensure you replace this with your actual key pair name

  security_groups = [aws_security_group.bastion_sg.name]
   
# Ensure the instance receives a public IP address
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Create the NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pb_subnet_1a.id

  tags = {
    Name = "nat-gateway"
  }
}

# Create the private subnet
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "private-subnet-1a"
  }
}

# Create the Route Table for the Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = local
  }

  tags = {
    Name = "private_rt"
  }
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "private_subnet_1a_assoc" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt.id
}

# Create a Security Group for the Private Instances
resource "aws_security_group" "control_plane_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "control_plane_sg"
  }
}

# Create a Security Group for the Private Instances
resource "aws_security_group" "worker_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "worker_sg"
  }
}

# Launch two EC2 instances in the private subnet

resource "aws_instance" "control-plane" {
  ami           = "ami-04cdc91e49cb06165" # Replace with a suitable AMI for your region
  instance_type = "t3.small" # Choose the instance type based on your needs
  subnet_id     = aws_subnet.private_subnet_1a.id
  key_name       = "short-video" # Ensure you replace this with your actual key pair name

  security_groups = [aws_security_group.control_plane_sg.name]

  associate_public_ip_address = false

  tags = {
    Name = "control-plane"
  }
}

resource "aws_instance" "worker-1" {
  ami           = "ami-04cdc91e49cb06165" # Replace with a suitable AMI for your region
  instance_type = "t3.small" # Choose the instance type based on your needs
  subnet_id     = aws_subnet.private_subnet_1a.id
  key_name       = "short-video" # Ensure you replace this with your actual key pair name

  security_groups = [aws_security_group.worker_sg.name]

  associate_public_ip_address = false

  tags = {
    Name = "worker-1"
  }
}
