resource "aws_iam_role" "codebuild-role" {
  description = "Codebuild Service Role"
  name        = "${var.project}-codebuild-role"
  path        = "/${var.tenant}/${var.project}/${var.environment}/${data.aws_region.current.name}/"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "codebuild-policy" {
  name = "codebuild-policy"
  role = aws_iam_role.codebuild-role.name

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Resource": [
				"*"
			],
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": [
				"*"
			]
		},
		{
			"Action": [
				"ecr:BatchCheckLayerAvailability",
				"ecr:CompleteLayerUpload",
				"ecr:GetAuthorizationToken",
				"ecr:InitiateLayerUpload",
				"ecr:PutImage",
				"ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
				"ecr:UploadLayerPart"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"ssm:GetParameters",
				"ssm:GetParametersByPath"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codedeploy:CreateDeployment",
				"codedeploy:GetApplication",
				"codedeploy:GetApplicationRevision",
				"codedeploy:GetDeployment",
				"codedeploy:GetDeploymentConfig",
				"codedeploy:RegisterApplicationRevision"
			],
			"Resource": "*",
			"Effect": "Allow"
		},





		{
			"Effect": "Allow",
			"Action": [
				"codebuild:CreateReportGroup",
				"codebuild:CreateReport",
				"codebuild:UpdateReport",
				"codebuild:BatchPutTestCases",
				"codebuild:BatchPutCodeCoverages"
			],
			"Resource": [
				"*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"iam:CreateServiceLinkedRole"
			],
			"Resource": "*",
			"Condition": {
				"StringEquals": {
					"iam:AWSServiceName": [
						"replication.ecr.amazonaws.com"
					]
				}
			}
		},
		{
			"Effect": "Allow",
			"Resource": [
				"arn:aws:s3:::*"
			],
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:GetBucketAcl",
				"s3:GetBucketLocation"
			]
		},
		{
            "Effect": "Allow",
            "Action": [
            "secretsmanager:GetSecretValue"
            ],
            "Resource": "arn:aws:secretsmanager:eu-west-1:************:secret:/github/******/sensitive/pat/default-PoO1N9"
        },
        {
            "Effect": "Allow",
            "Action": [
            "kms:Decrypt"
        ],
            "Resource": "arn:aws:kms:eu-west-1:***************:key/26d2d9e3-54ac-4ff6-80ae-a2d382f89e7c"
    }
	]
}
EOF
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.project}-codebuild"
  description   = "Codebuild with Terraform"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_LARGE"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.tenant}/${var.project}/application"

    }
    environment_variable {
      name  = "TASK_EXECUTION_ROLE"
      value = local.webapp_ecs_task_execution_role_arn #var.task_execution_role
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "FULL_ECR_REGISTRY"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.tenant}/${var.project}/application"
    }

    environment_variable {
      name  = "TASK_ROLE"
      value = local.webapp_ecs_task_role_arn #var.task_role
    }

    environment_variable {
      name  = "ECS_LOGGROUP"
      value = "/ecs/${var.tenant}-web-app"
    }
    environment_variable {
      name  = "ECS_LOG_PREFIX"
      value = "${var.tenant}-${var.project}"
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = "${var.tenant}-web-app"
    }
    environment_variable {
      name  = "TASK_DEF_FAMILY"
      value = "${var.tenant}-web-app-task"
    }

  }

  source {
    type            = "CODEPIPELINE"
    location        = local.full_repo_id
    git_clone_depth = 1
    buildspec       = local.buildspec
    git_submodules_config {
      fetch_submodules = true
    }
  }
}
