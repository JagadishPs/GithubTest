locals {
  account_id                         = data.aws_caller_identity.current.account_id
  full_repo_id                       = "${var.git_org}/${var.git_repo}"
  buildspec                          = "iac/buildspec/${var.environment}/${data.aws_region.current.name}/buildspec.yaml" 
  webapp_ecs_task_execution_role_arn = data.terraform_remote_state.compute.outputs.ecs_task_execution_role_arn
  webapp_ecs_task_role_arn           = data.terraform_remote_state.compute.outputs.ecs_task_role_arn
}
