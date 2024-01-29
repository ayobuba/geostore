locals {
  name    = "geostore"
  region  = "eu-central-1"
  region2 = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }
}


#module "geostore_postgres_rds" {
#  source  = "terraform-aws-modules/rds/aws"
#  version = "6.3.1"
#  # insert the 1 required variable here
#  identifier = "${local.name}-geostore"
#
#
#  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
#  engine               = "postgres"
#  engine_version       = "15"
#  family               = "postgres15" # DB parameter group
#  major_engine_version = "15"         # DB option group
#  instance_class       = "db.t4g.small"
#
#  allocated_storage     = 20
#  max_allocated_storage = 100
#  publicly_accessible = true
#
#  iam_database_authentication_enabled = true
#
#  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
#  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
#  # user cannot be used as it is a reserved word used by the engine"
#  db_name  = "${local.name}DB"
#  username = local.name
#  password = "geostore123"
##  password = "var.rds_password"
#  port     = 5432
#  manage_master_user_password = false
#
#  multi_az               = false
#  db_subnet_group_name   = module.geostore-vpc.database_subnet_group
#  vpc_security_group_ids = flatten([module.security_group.security_group_id])
#
#  maintenance_window              = "Mon:00:00-Mon:03:00"
#  backup_window                   = "03:00-06:00"
#  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
#  create_cloudwatch_log_group     = false
#
#  backup_retention_period = 1
#  skip_final_snapshot     = true
#  deletion_protection     = false
#
#  performance_insights_enabled          = false
#  performance_insights_retention_period = 7
#  create_monitoring_role                = true
#  monitoring_interval                   = 60
#  monitoring_role_name                  = "example-monitoring-role-name"
#  monitoring_role_use_name_prefix       = true
#  monitoring_role_description           = "Description for monitoring role"
#
#  parameters = [
#    {
#      name  = "autovacuum"
#      value = 1
#    },
#    {
#      name  = "client_encoding"
#      value = "utf8"
#    }
#  ]
#
#  tags = {
#    "Terraform"   = "true"
#    "Environment" = "dev"
#  }
#  db_option_group_tags = {
#    "Sensitive" = "low"
#  }
#  db_parameter_group_tags = {
#    "Sensitive" = "low"
#  }
#}

module "geostore-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  tags = local.tags
}




##Create postgresql database terraform
#variable "rds_password" {
#
#}
#variable "name" {
#
#}
#variable "stage" {
#
#}
#module "geostore_postgres_rds" {
#  source  = "terraform-aws-modules/rds/aws"
#  version = "6.3.1"
#  # insert the 1 required variable here
#  identifier = "geostore"
#
#
#  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
#  engine               = "postgres"
#  engine_version       = "15"
#  family               = "postgres15" # DB parameter group
#  major_engine_version = "15"         # DB option group
#  instance_class       = "db.t4g.small"
#
#  allocated_storage     = 20
#  max_allocated_storage = 100
#  publicly_accessible = true
#
#  iam_database_authentication_enabled = true
#
#  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
#  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
#  # user cannot be used as it is a reserved word used by the engine"
#  db_name  = var.name
#  username = var.name
#  password = "geostore123"
##  password = "var.rds_password"
#  port     = 5432
#  manage_master_user_password = true
#
#  multi_az               = false
#  db_subnet_group_name   = "default-vpc-3cb60655"
#  vpc_security_group_ids = ["sg-09d8d3049ec72549b"]
#
#  maintenance_window              = "Mon:00:00-Mon:03:00"
#  backup_window                   = "03:00-06:00"
#  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
#  create_cloudwatch_log_group     = false
#
#  backup_retention_period = 1
#  skip_final_snapshot     = true
#  deletion_protection     = false
#
#  performance_insights_enabled          = false
#  performance_insights_retention_period = 7
#  create_monitoring_role                = true
#  monitoring_interval                   = 60
#  monitoring_role_name                  = "example-monitoring-role-name"
#  monitoring_role_use_name_prefix       = true
#  monitoring_role_description           = "Description for monitoring role"
#
#  parameters = [
#    {
#      name  = "autovacuum"
#      value = 1
#    },
#    {
#      name  = "client_encoding"
#      value = "utf8"
#    }
#  ]
#
#  tags = {
#    "Terraform"   = "true"
#    "Environment" = "dev"
#  }
#  db_option_group_tags = {
#    "Sensitive" = "low"
#  }
#  db_parameter_group_tags = {
#    "Sensitive" = "low"
#  }
#}
