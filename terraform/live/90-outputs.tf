output "instance-ip" {
  value = aws_instance.web_server.public_ip
}

output "instance-dns" {
  value = aws_instance.web_server.public_dns
}

#output "database-ip" {
#  value = module.geostore_postgres_rds.db_instance_endpoint
#}