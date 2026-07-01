resource "aws_iam_role" "codepipeline-role" {
  description = "CodePipeline Service Role"
  name        = "${var.tenant}-${var.project}-${var.environment}-codepipeline-role" #var.codepipeline_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline-policy" {
  name = "${var.tenant}-${var.project}-${var.environment}-codepipeline-policy" #var.codepipeline_policy_name
  role = aws_iam_role.codepipeline-role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "ecs:RegisterTaskDefinition",
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:UpdateService"
      ],
      "Resource": "*"
    },
    {
       "Action": "iam:PassRole",
       "Effect": "Allow",
       "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:CreateConnection",
        "codestar-connections:GetConnection",
        "codestar-connections:UseConnection"
      ],
      "Resource": "*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:GetApplication",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:GetApplicationRevision",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Resource" : [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline-role.arn
  artifact_store {
    location = "cicd-${data.aws_caller_identity.current.account_id}.codepipeline-artifacts.${data.aws_region.current.name}"               
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.this.arn
        FullRepositoryId = local.full_repo_id
        BranchName       = var.git_branch_name
      }
    }
  }


  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  dynamic "stage" {

    for_each = var.codepipeline_manual_approval ? [true] : []
    content {

      name = "Manual-Approval"
      action {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }


  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName                = "${var.tenant}-${var.project}-ecsdeploy"#"AppECS-warehouse-webapp-cluster-warehouse-webapp-service-manual"
        DeploymentGroupName            = "${var.tenant}-${var.project}-ecs-dpg" #"DgpECS-warehouse-webapp-cluster-warehouse-webapp-service-manual" 
        TaskDefinitionTemplateArtifact = "build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "build_output"
        AppSpecTemplatePath            = "appspec.yaml"
        Image1ArtifactName             = "build_output"
        Image1ContainerName            = "IMAGE_NAME"
      }
    }
  }
}
