terraform {
    required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
        }
    }

    required_version = ">= 1.2.0"
}

provider "aws" {
    region  = "ap-northeast-2"
}

resource "aws_key_pair" "my_labtop" {
    key_name   = "my_labtop"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "prometheus" {
    name        = "prometheus_sg"
    description = "security group for prometheus server"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 9090
        to_port     = 9090
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

resource "aws_security_group" "app_server" {
    name        = "app_sg"
    description = "security group for app server"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 9100
        to_port     = 9100
        protocol    = "tcp"
        security_groups = [aws_security_group.prometheus.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "prometheus" {
    ami           = "ami-0572f73f0a5650b33"
    instance_type = "t2.micro"

    vpc_security_group_ids = [aws_security_group.prometheus.id]

    key_name = aws_key_pair.my_labtop.key_name
    tags = {
        Name = "PrometheusServer"
    }
}

resource "aws_instance" "app_server" {
    ami           = "ami-0572f73f0a5650b33"
    instance_type = "t2.micro"

    vpc_security_group_ids = [aws_security_group.app_server.id]

    key_name = aws_key_pair.my_labtop.key_name
    tags = {
        Name = "AppServer"
    }
}

output "prometheus_public_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.prometheus.public_ip
}

output "app_server_public_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.app_server.public_ip
}