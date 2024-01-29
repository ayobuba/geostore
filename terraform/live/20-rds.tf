variable "db_name" {
  default = ""
}
variable "db_subnet_group_name" {
  default = ""
}
variable "vpc_security_group_ids" {
  default = ""
}
variable "username" {
  default = ""
}
variable "identifier" {
  default = ""
}
variable "instance_class" {
  default = ""
}
variable "allocated_storage" {
  default = ""
}
resource "aws_db_instance" "geostore" {

  allocated_storage       = var.allocated_storage
  availability_zone       = "${var.aws_region}a"
  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  db_name              = var.db_name
  db_subnet_group_name = var.db_subnet_group_name

  engine                              = "postgres"
  engine_version                      = "15.4"
  iam_database_authentication_enabled = true
  identifier                          = var.identifier
  instance_class                      = var.instance_class
  max_allocated_storage               = 1000
  monitoring_interval                 = 0
  multi_az                            = false
  network_type                        = "IPV4"
  port                                = 5432
  publicly_accessible                 = true
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  username                            = var.username
  password                            = var.db_password
  vpc_security_group_ids              = flatten(var.vpc_security_group_ids)
}

output "db_endpoint" {
  value = aws_db_instance.geostore.endpoint
}


