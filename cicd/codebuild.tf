resource "aws_s3_bucket" "age_build_bucket" {
  bucket = "${var.project}-${var.environment}-build-bucket"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name        = "${var.project}-${var.environment}-build-bucket"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_s3_bucket" "age_data_bucket" {
  bucket = "${var.project}-${var.environment}-data-bucket"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name        = "${var.project}-${var.environment}-data-bucket"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_codebuild_source_credential" "age_codebuild_credentials" {
  auth_type   = "BASIC_AUTH"
  server_type = "BITBUCKET"
  user_name   = var.bitbucketUsername
  token       = var.bitbucketToken
}

resource "aws_codebuild_webhook" "age_codebuild_webhook" {
  project_name = aws_codebuild_project.age_codebuild_source.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH,PULL_REQUEST_MERGED"
    }
    filter {
      type    = "HEAD_REF"
      pattern = var.bitbucketRepositoryBranch
    }
  }
}

resource "aws_codebuild_project" "age_codebuild_source" {
  name          = "${var.project}-${var.environment}-codebuild-source-project"
  service_role  = var.codebuildRole
  
  artifacts {
    type = "S3"
    location = aws_s3_bucket.age_build_bucket.bucket
    packaging = "ZIP"
    path = "age-server"
    name = "source"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "BITBUCKET"
    location        = var.bitbucketRepositoryId
    auth {
      type = "OAUTH"
      resource = aws_codebuild_source_credential.age_codebuild_credentials.arn
    }
    buildspec = <<BUILDSPEC
    version: 0.2
    phases:
      build:
        commands:
          - echo Pushing to S3 Bucket
    artifacts:
      files:
        - '**/*'
    BUILDSPEC
  }
  source_version = var.bitbucketRepositoryBranch
}

data "aws_ssm_parameter" "aws_access_key_id" {
  name = var.awsAccessKeyIdParameter
}

data "aws_ssm_parameter" "aws_secret_access_key" {
  name = var.awsSecretAccessKeyParameter
}

data "aws_ssm_parameter" "database_username" {
  name = var.databaseUsernameParameter
}

data "aws_ssm_parameter" "database_password" {
  name = var.databasePasswordParameter
}

data "aws_ssm_parameter" "jwt_secret" {
  name = var.jwtSecretParameter
}

data "aws_ssm_parameter" "comet_chat_app_id" {
  name = var.cometChatAppIdParameter
}

data "aws_ssm_parameter" "comet_chat_api_key" {
  name = var.cometChartApiKeyParameter
}



# Codebuild project
resource "aws_codebuild_project" "age_codebuild" {
  name          = "${var.project}-${var.environment}-codebuild-pipeline-project"
  service_role  = var.codebuildRole
  
  artifacts {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = var.vpcId
    subnets = var.codebuildPrivateSubnetIds
    security_group_ids = var.codebuildSecurityGroup
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name = "REPOSITORY_URI"
      value = var.ecrRepositoryUri
    }
    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = var.awsRegion
    }
    environment_variable {
      name = "IMAGE_TAG"
      value = var.ecrImageTag
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
    version: 0.2
    phases:
      install:
        commands:
          - nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 --storage-driver=overlay2 &
          - timeout 15 sh -c "until docker info; do echo .; sleep 1; done"
      pre_build:
        commands:
          - echo Updating .env file
          - cp .env.example .env
          - sed -i '/DB_HOST=/c\DB_HOST=${var.databaseEndpoint}' .env
          - sed -i '/DB_DATABASE=/c\DB_DATABASE=AGE' .env
          - db_uname=$(aws ssm get-parameter --name "${var.databaseUsernameParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/DB_USERNAME=/c\DB_USERNAME=$db_uname" .env
          - db_pass=$(aws ssm get-parameter --name "${var.databasePasswordParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/DB_PASSWORD=/c\DB_PASSWORD=$db_pass" .env
          - aws_key_id=$(aws ssm get-parameter --name "${var.awsAccessKeyIdParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/AWS_ACCESS_KEY_ID=/c\AWS_ACCESS_KEY_ID=$aws_key_id" .env
          - aws_key=$(aws ssm get-parameter --name "${var.awsSecretAccessKeyParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/AWS_SECRET_ACCESS_KEY=/c\AWS_SECRET_ACCESS_KEY=$aws_key" .env
          - sed -i '/AWS_DEFAULT_REGION=/c\AWS_DEFAULT_REGION=${var.awsRegion}' .env
          - sed -i '/AWS_BUCKET=/c\AWS_BUCKET=${aws_s3_bucket.age_data_bucket.id}' .env
          - sed -i '/S3_BASE_FOLDER=/c\S3_BASE_FOLDER=${var.applicationS3Folder}' .env
          - jwt=$(aws ssm get-parameter --name "${var.jwtSecretParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/JWT_SECRET=/c\JWT_SECRET=$jwt" .env
          - sed -i '/COMET_CHAT_URL=/c\COMET_CHAT_URL=${var.cometChatUrl}' .env
          - c_app_id=$(aws ssm get-parameter --name "${var.cometChatAppIdParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/COMET_CHAT_APP_ID=/c\COMET_CHAT_APP_ID=$c_app_id" .env
          - c_api_key=$(aws ssm get-parameter --name "${var.cometChartApiKeyParameter}" --with-decryption | jq -r '.Parameter.Value')
          - sed -i "/COMET_CHAT_API_KEY=/c\COMET_CHAT_API_KEY=$c_api_key" .env
          - echo Logging in to Amazon ECR...
          - aws --version
          - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      build:
        commands:
          - echo Build started on `date`
          - echo Building the Docker image...
          - echo Image_tag $IMAGE_TAG
          - docker build -t $REPOSITORY_URI:latest .
          - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG 
      post_build:
        commands:
          - echo Build completed on `date`
          - echo Pushing the Docker images...
          - docker push $REPOSITORY_URI:$IMAGE_TAG
          - echo Writing image definitions file...
          - printf '[{"name":"${var.project}-${var.environment}-task-definition","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
    artifacts:
        files: imagedefinitions.json
    BUILDSPEC
  }
}