# get the latest ubuntu image ami
data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "my_labtop" {
  key_name   = "my_labtop"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "vpc" {
  source = "../modules/vpc"

  ENVIRONMENT = var.ENVIRONMENT
  AWS_REGION  = var.AWS_REGION
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [module.vpc.default_sg_id]
  subnet_id              = module.vpc.public-1_subnets

  key_name = aws_key_pair.my_labtop.key_name
  tags = {
    Name = "MasterServer"
  }
}