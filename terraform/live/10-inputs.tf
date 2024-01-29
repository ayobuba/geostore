variable "access_key" {}

variable "secret_key" {}

variable "aws_region" {
  type        = string
  description = "AWS Region."
}

variable "codebuild_service_role" {}
variable "encryption_key" {}
variable "source_version" {}

variable "repository_id" {
  default = ""
}
variable "branch_name" {
  default = ""
}
variable "service_pipeline_arn" {
  default = ""
}



variable "db_password" {
  default = ""
}