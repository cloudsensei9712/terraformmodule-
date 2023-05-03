resource "aws_codepipeline" "frontend_codepipeline" {
  name     = "${var.project}-${var.environment}-frontend-pipeline"
  role_arn = var.frontend_pipeline_role

  artifact_store {
    location = aws_s3_bucket.backend_codepipeline_bucket.bucket
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
        ConnectionArn    = var.codestar_connection_arn #aws_codestarconnections_connection.backend_codestar_connection.arn
        FullRepositoryId = var.front_end_repository
        BranchName       = var.front_end_repository_branch
        
      }
    }
  }

  dynamic "stage" {
   for_each = var.create_manual_approval ? [ 0 ]: [ 0 ]
   content {
     name = "ManualApproval"
     action {
       name     = "ApproveDeployment"
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
      name             = "CreateBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}-${var.environment}-backend-build-project"
      }
    }
  }

  stage {
    name = "StoreBuild"

    action {
      name            = "StoreBuild"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      #output_artifacts = [ "build_s3" ]
      version         = "1"

       configuration = {
        "BucketName" = "${var.project}-${var.environment}-backend-pipleline-artifacts"
        "Extract"    = "false"
        "ObjectKey"  = "build.zip"
      }
    }
  }

  stage {
    name = "Deploy"

   action {
      name             = "DeployBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${var.project}-${var.environment}-backend-deploy-project"
        EnvironmentVariables =  "[{\"name\":\"S3_BUCKET\",\"value\":\"${var.project}-${var.environment}-backend-pipleline-artifacts\",\"type\":\"PLAINTEXT\"},{\"name\":\"FUNCTION_NAME\",\"value\":\"${var.project}-${var.environment}-${var.lambda_function_name}\",\"type\":\"PLAINTEXT\"}]"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "backend_codestar_connection" {
  name          = "codeConnection-Alumini"#"${var.project}-${var.environment}-codestar-connect"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "backend_codepipeline_bucket" {
  bucket = "${var.project}-${var.environment}-backend-pipleline-artifacts"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.backend_codepipeline_bucket.id
  acl    = "private"
}