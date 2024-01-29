data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_availability_zones" "available" {}

provider "aws" {
  region = var.aws_region
  # Allow any 2.x version of the AWS provider
  //version = "~> 3.0"

  access_key = var.access_key
  secret_key = var.secret_key
}


terraform {
  required_version = ">= 1.3.9"
  #  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "production-tfstate-bucket-557968956216"
    key            = "geostore/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "production-tfstate-bucket-lock-dynamodb-557968956216"
  }
}


#locals {
#  region      = "us-east-2"
#  environment = "dev"
#  additional_tags = {
#    Owner      = "organization_name"
#    Expires    = "Never"
#    Department = "Engineering"
#  }
#}

#module "backend" {
#  source                       = "squareops/tfstate/aws"
#  version                      = "1.0.2"
#  logging                      = true
#  bucket_name                  = "production-tfstate-bucket" #unique global s3 bucket name
#  environment                  = local.environment
#  force_destroy                = true
#  versioning_enabled           = true
#  cloudwatch_logging_enabled   = true
#  log_retention_in_days        = 90
#  log_bucket_lifecycle_enabled = true
#  s3_ia_retention_in_days      = 90
#  s3_galcier_retention_in_days = 180
#}
#
#output "bucket_name" {
#  value = module.backend.state_bucket_name
#}
#
#
#output "bucket_dynamodb_table_name" {
#  value = module.backend.dynamodb_table_name
#}


#output "log_bucket_name" {
#  value = module.backend.log_bucket_name
#}



