resource "aws_codepipeline" "frontend_codepipeline" {
  name     = "${var.project}-${var.environment}-frontend-pipeline"
  role_arn = var.frontend_pipeline_role

  artifact_store {
    location = aws_s3_bucket.frontend_codepipeline_bucket.bucket
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
        ConnectionArn    = var.codestar_connection_arn #aws_codestarconnections_connection.frontend_codestar_connection.arn
        FullRepositoryId = var.front_end_repository
        BranchName       = var.front_end_repository_branch
        
      }
    }
  }

  dynamic "stage" {
   for_each = var.create_manual_approval ? [ 1 ]: [ 0 ]
   content {
     name = "Manual Approval"
     action {
       name     = "Approve Deployment"
       category = "Approval"
       owner    = "AWS"
       provider = "Manual"
       version  = "1"
     }
   }
 }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}-${var.environment}-frontend-project"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

       configuration = {
        "BucketName" = var.static_web_bucket_name
        "Extract"    = "true"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "frontend_codestar_connection" {
  name          = "codeConnection-Alumini"#"${var.project}-${var.environment}-codestar-connect"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "frontend_codepipeline_bucket" {
  bucket = "${var.project}-${var.environment}-frontend-pipleline-artifacts"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.frontend_codepipeline_bucket.id
  acl    = "private"
}