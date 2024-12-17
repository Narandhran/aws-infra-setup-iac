terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.0"
    }
  }
  backend "s3" {
    bucket               = "bckt-tf-state-b1os"
    key                  = "dev"
    region               = "eu-west-1"
    encrypt              = true
    profile              = "b1os"
    workspace_key_prefix = "b1os"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = {
      Env       = terraform.workspace
      CreatedBy = "Terraform"
      Project   = var.ProjectName
    }
  }
}
