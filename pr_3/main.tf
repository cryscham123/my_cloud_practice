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

resource "aws_security_group" "master" {
    name        = "master_sg"

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

resource "aws_security_group" "worker" {
    name        = "worker_sg"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 6443
        to_port     = 6443
        protocol    = "tcp"
        security_groups = [aws_security_group.master.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "master" {
    ami           = "ami-0572f73f0a5650b33"
    instance_type = "t2.micro"

    vpc_security_group_ids = [aws_security_group.master.id]

    key_name = aws_key_pair.my_labtop.key_name
    tags = {
        Name = "MasterServer"
    }
}

resource "aws_instance" "worker" {
    count         = 2
    ami           = "ami-0572f73f0a5650b33"
    instance_type = "t2.micro"

    vpc_security_group_ids = [aws_security_group.worker.id]

    key_name = aws_key_pair.my_labtop.key_name
    tags = {
        Name = "WorkerServer${count.index + 1}"
    }
}

output "master_public_ip" {
  value       = aws_instance.master.public_ip
}

output "worker_public_ip" {
  value       = aws_instance.worker.*.public_ip
}