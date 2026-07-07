variable "project" {
  default = "web-app"
}

variable "tenant" {
  type    = string
  default = "warehouse"
}

variable "environment" {
  default = "stag"
}

variable "owner" {
  type    = string
  default = " "
}

variable "cost_centre" {
  type    = string
  default = "warehouse"
}

variable "application" {
  type    = string
  default = "web-application-service"
}

variable "codebuild_name" {
  description = "Codebuild project name"
  type        = string
  default     = "webapp-codebuild"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = number
  default     = " "
}

variable "git_repo_name" {
  description = "Github Repository for the Application"
  type        = string
  default     = "Web-Application"
}

variable "git_branch_name" {
  description = "Github Branch for the Repository"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "Github Token for the Repository"
  type        = string
  default     = ""
}

variable "font_awesome_token" {
  description = "Fontawesome Token"
  type        = string
  default     = ""
}

variable "cluster_name" { 
  description = "ECS cluster name"
  type = string
  default = "warehouse-webapp-cluster"
}

variable "service_name"{
  description = "Service name"
  type = string
  default = "warehouse-webapp-service"
}

variable "target_group_blue_ecs_name" {
  description = "Blue target group name"
  type = string
  default = "warehouse-stag-blue-tg"
}
variable "target_group_green_ecs_name" {
  description = "green target group name"
  type = string
  default = "warehouse-stag-green-tg"  
}

variable "ecr_repo" {
  description = "ECR Repository"
  type        = string
  default     = "warehouse/web-application/application"
}

variable "s3_bucket" {
  description = "Name of artifact bucket"
  type        = string
  default     = "cicd-ID.codepipeline-artifacts.us-west-2"
}

variable "buildspec_path" {
   description  = "buildspec file path"
   default      = "iac/buildspec"
}

variable "codepipeline_manual_approval" {
  description = "enable of disable manual approval phase in codepipeline"
  default = false
}

variable "build_timeout" {
  type = number
  default = 120
}

      "owner"                    = var.owner
      "project"                  = var.project
      "application"              = var.application
      "cost-centre"              = var.cost_centre
      "tenant"                   = var.tenant
      "environment"              = var.environment
      "iac"                      = "terraform"
      "security:compliance-gdpr" = var.sec_gdpr
      "security:compliance-pci"  = var.sec_pci
      "security:customer-data"   = var.sec_customer_data
      "security:confidentiality" = var.sec_confidentiality
      "git:org"                  = var.git_org
      "git:repo"                 = var.git_repo
