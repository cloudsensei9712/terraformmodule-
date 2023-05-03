data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.yml")}"
  
}

resource "aws_codebuild_project" "static_web_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.project}-${var.environment}-frontend-project"
  queued_timeout = 480
  service_role = var.frontend_codebuild_role
 tags = {
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }

  artifacts {
    encryption_disabled    = false
    name                   = "${var.environment}-static-web-build"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}