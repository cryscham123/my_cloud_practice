resource "aws_db_subnet_group" "mariadb" {
  name       = "mariadb"
  subnet_ids = [aws_subnet.private.id]
}

resource "aws_db_parameter_group" "mariadb" {
  family      = "mariadb10.4"
  name        = "mariadb"
  description = "mariadb"

  parameter {
    name  = "max_connections"
    value = "1000"
  }
}

resource "aws_db_instance" "mariadb" {
  identifier             = "mariadb"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mariadb"
  engine_version         = "10.4"
  instance_class         = "db.t2.micro"
  db_name                = "mariadb"
  username               = "admin"
  password               = "password"
  db_subnet_group_name   = aws_db_subnet_group.mariadb.name
  parameter_group_name   = aws_db_parameter_group.mariadb.name
  vpc_security_group_ids = [aws_security_group.db.id]
}