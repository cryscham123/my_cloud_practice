output "master_public_ip" {
  description = "The public IP address of the master server"
  value       = aws_instance.main.public_ip
}