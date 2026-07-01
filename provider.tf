terraform {
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.0.0, < 5.0.0"
    }

  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "owner"                    = var.owner
      "project"                  = var.project
      "application"              = var.application
      "cost-centre"              = var.cost_centre
      "tenant"                   = var.tenant
      "environment"              = var.environment
      "iac"                      = "terraform"
      "git:org"                  = var.git_org
      "git:repo"                 = var.git_repo
    }
  }
}
