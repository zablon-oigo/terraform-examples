provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}			
# Default VPC 
data "aws_vpc" "vpc" {
    default = true
}

data "aws_subnet" "subnet1" {
    vpc_id = data.aws_vpc.vpc.id
    availability_zone = "us-east-1a"
}

data "aws_subnet" "subnet2" {
    vpc_id = data.aws_vpc.vpc.id
    availability_zone = "us-east-1b"
}
# Creating Security Group for EC2
resource "aws_security_group" "ec2_sg" {
    name        = "NLBserver-SG"
    description = "Security Group to allow traffic to EC2"
    vpc_id = data.aws_vpc.vpc.id
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# Creating Key pair for EC2 
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "my_key" {
  key_name   = "myKey"
  public_key = tls_private_key.key.public_key_openssh
}
# Launching EC2 Instance 
resource "aws_instance" "ec2" {
    ami                    = "ami-04823729c75214919"
    instance_type          = "t2.micro"
    key_name               = aws_key_pair.my_key.key_name
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    subnet_id              = data.aws_subnet.subnet1.id
    user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<html> <h1> Response coming from server </h1> </html>" >> /var/www/html/index.html
    EOF
    tags = {
        Name = "NLBEC2server"
    }
}		