
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


resource "aws_codebuild_project" "geostore" {
  badge_enabled      = false
  encryption_key     = var.encryption_key
  name               = "geostore-build"
  project_visibility = "PRIVATE"
  service_role       = var.codebuild_service_role
  source_version     = var.branch_name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
  }

  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/${var.repository_id}"
    report_build_status = false
    type                = "GITHUB"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "geostore" {
  name               = "geostore-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.geostore.name
}

resource "aws_codedeploy_app" "geostore" {
  compute_platform = "Server"
  name             = "geostore"
}

resource "aws_sns_topic" "geostore" {
  name = "geostore-topic"
}

resource "aws_codedeploy_deployment_group" "geostore" {
  app_name               = aws_codedeploy_app.geostore.name
  deployment_group_name  = "geostore-group"
  service_role_arn       = aws_iam_role.geostore.arn
  deployment_config_name = aws_codedeploy_deployment_config.geostore.id

  ec2_tag_set {
    ec2_tag_filter {
      key   = "name"
      type  = "KEY_AND_VALUE"
      value = "geostore-webServer"
    }

    ec2_tag_filter {
      key   = "app"
      type  = "KEY_AND_VALUE"
      value = "geostore"
    }
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "geostore-trigger"
    trigger_target_arn = aws_sns_topic.geostore.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }

  outdated_instances_strategy = "UPDATE"
}

resource "aws_codedeploy_deployment_config" "geostore" {
  deployment_config_name = "geostore-deployment-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}

resource "aws_codepipeline" "geostore" {
  name          = "geostore-pipeline"
  pipeline_type = "V2"
  role_arn      = var.service_pipeline_arn

  artifact_store {
    location = "codepipeline-eu-central-1-282839018752"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "BranchName"           = var.branch_name
        "ConnectionArn"        = aws_codestarconnections_connection.geostore.arn
        "FullRepositoryId"     = var.repository_id
        "OutputArtifactFormat" = "CODE_ZIP"
      }
      input_artifacts = []
      name            = "Source"
      namespace       = "SourceVariables"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      region    = "eu-central-1"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = aws_codebuild_project.geostore.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name      = "Build"
      namespace = "BuildVariables"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      region    = var.aws_region
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ApplicationName"     = aws_codedeploy_deployment_group.geostore.app_name
        "DeploymentGroupName" = aws_codedeploy_deployment_group.geostore.deployment_group_name
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      namespace        = "DeployVariables"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeploy"
      region           = "eu-central-1"
      run_order        = 1
      version          = "1"
    }
  }
}

resource "aws_codestarconnections_connection" "geostore" {
  name          = "geostaoe-pipeline"
  provider_type = "GitHub"
  tags          = {}
  tags_all      = {}
}

