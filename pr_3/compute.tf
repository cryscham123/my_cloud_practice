# get the latest ubuntu image ami
data "aws_ami" "latest-ubuntu" {
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

resource "aws_instance" "master" {
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.master.id]

  key_name = aws_key_pair.my_labtop.key_name
  tags = {
    Name = "MasterServer"
  }
}

resource "aws_instance" "worker" {
  count         = 2
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.worker.id]

  key_name = aws_key_pair.my_labtop.key_name
  tags = {
    Name = "WorkerServer${count.index + 1}"
  }
}