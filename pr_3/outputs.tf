output "master_public_ip" {
  description = "The public IP address of the master server"
  value       = aws_instance.main.public_ip
}

output "mariadb_endpoint" {
  description = "The endpoint of the MariaDB instance"
  value       = aws_db_instance.mariadb.endpoint
}