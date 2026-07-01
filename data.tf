data "terraform_remote_state" "compute" {
 backend = "remote"

  config = {
    organization = "*******"
    workspaces = {
      name = "${var.tenant}-${var.project}-compute-aws-${data.aws_ssm_parameter.environment.value}-${data.aws_region.current.name}"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available_azs" {}

data "aws_ssm_parameter" "environment" {
  name = "/tags/environment"
}
