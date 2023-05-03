variable "project" {
  type = string
  default = "age"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "createdBy" {
  type = string
  default = "Northbay"
}

variable "awsRegion" {
  type = string
  default = "us-west-1"
  description = "Current AWS Region"
}

variable "awsAccountId" {
  type = string
  default = "us-west-1"
  description = "Current AWS Region"
}

variable "ecrRepositoryUri" {
  type = string
  description = "ECR Repository Image"
  
}

variable "ecrImageTag" {
  type = string
  default = "dev"
  description = "Image Tag for the new Image"
}


variable "codebuildRole" {
  type = string
  description = "Arn of the Role required for Codebuild"
}
#  CodeBuild Varaibles


variable "ecsClusterName" {
  type = string
  description = "Name of the ECS Cluster to deploy containers"
}
variable "ecsServiceName" {
  type = string
  description = "Name of the ECS Service to deploy containers"
}

variable "codePipelineRoleArn" {
  type = string
  description = "Arn of the Role required for CodePipeline"
}

variable "vpcId" {
  type = string
  description = "Id of the VPC"
}

variable "codebuildPrivateSubnetIds" {
  type = list(string)
  description = "List of Subnet Id for CodeBuild Project"
}

variable "codebuildSecurityGroup" {
  type = list(string)
  description = "Security Group Id for CodeBuild"
}

variable "deploymentTimeout" {
  type = number
  default = 15
  description = "Deployment Timeout for Code Pipeline"
}

variable "bitbucketRepositoryBranch" {
  type = string
  description = "Repository Branch for the source control repository"
}

variable "bitbucketRepositoryId" {
  type = string
  description = "Id of the Bitbucket repository"
}

variable "bitbucketUsername" {
  type = string
  description = "User Name of the bitbucket user used to access the repository"
}

variable "bitbucketToken" {
  type = string
  description = "App Password for bitbucket"
}

variable "databaseEndpoint" {
  type = string
  description = "RDS DB Endpoint to be updated in .env file"
}

variable "databaseUsernameParameter" {
  type = string
  description = "SSM Parameter name for database username"
}

variable "databasePasswordParameter" {
  type = string
  description = "SSM Parameter name for database password"
}

variable "applicationS3Folder" {
  type = string
  description = "S3 Base folder to stored application data"
}

variable "jwtSecretParameter" {
  type = string
  description = "Paramter Path to JWT_SECRET"
}

variable "cometChatUrl" {
  type = string
  description = "CometChat API URL"
}
variable "cometChatAppIdParameter" {
  type = string
  description = "SSM Parameter name for comet chat app id"
}

variable "cometChartApiKeyParameter" {
  type = string
  description = "SSM Parameter name for comet chat api key"
}

variable "awsAccessKeyIdParameter" {
  type = string
  description = "SSM Parameter name for AWS Access Key Id"
}

variable "awsSecretAccessKeyParameter" {
  type = string
  description = "SSM Parameter name for AWS Secret Access Key"
}