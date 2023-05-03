resource "aws_s3_bucket" "age_artifact_bucket" {
  bucket = "${var.project}-${var.environment}-atrifacts-bucket"
  acl    = "private"

  tags = {
    Name        = "${var.project}-${var.environment}-atrifacts-bucket"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# CodePipeline 

resource "aws_codepipeline" "age_pipeline" {
  depends_on = [
    aws_codebuild_project.age_codebuild
  ]
  name     = "${var.project}-${var.environment}-codepipeline"
  role_arn = var.codePipelineRoleArn
  artifact_store {
    location = aws_s3_bucket.age_artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        S3Bucket           = aws_s3_bucket.age_build_bucket.bucket
        S3ObjectKey        = "age-server/source"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.age_codebuild.id
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      provider        = "ECS"
      run_order       = 1
      input_artifacts = ["BuildOutput"]
      configuration = {
        ClusterName       = var.ecsClusterName
        ServiceName       = var.ecsServiceName
        FileName          = "imagedefinitions.json"
        DeploymentTimeout = var.deploymentTimeout
      }
    }
  }
}